import UIKit
import OSLog

private let scanLog = Logger(subsystem: "com.example.casestudy1-qris", category: "ScanPresenter")

protocol ScanPresenting: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func viewWillDisappear()
    func didCaptureCode(_ raw: String)
    func didTapPickFromGallery()
    func didTapBack()
    func didConfirmSettingsAlert()
}

protocol ScanViewControlling: AnyObject {
    func startCameraSession()
    func stopCameraSession()
    func showError(_ message: String, allowsSettings: Bool, retryable: Bool)
    func setTorchAvailable(_ available: Bool)
}

final class ScanPresenter: ScanPresenting {

    private weak var view: ScanViewControlling?
    private let interactor: ScanInteracting
    private let router: ScanRouting

    /// Debounces double-fires from AVFoundation. Once we have a successful parse we
    /// ignore further frames until the user comes back.
    private var hasHandledCode = false
    private var lastErrorAt: Date?

    init(view: ScanViewControlling, interactor: ScanInteracting, router: ScanRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {}

    func viewWillAppear() {
        hasHandledCode = false
        view?.startCameraSession()
    }

    func viewWillDisappear() {
        view?.stopCameraSession()
    }

    func didCaptureCode(_ raw: String) {
        scanLog.info("didCaptureCode: raw=\(raw, privacy: .public)")
        guard !hasHandledCode else {
            scanLog.info("didCaptureCode: ignored — already handled")
            return
        }

        switch interactor.parse(raw) {
        case .success(let transaction):
            scanLog.info("didCaptureCode: parsed bank=\(transaction.bank, privacy: .public) amount=\(transaction.amount)")
            hasHandledCode = true
            view?.stopCameraSession()
            DispatchQueue.main.async { [weak self] in
                guard let self, let viewController = self.view as? UIViewController else { return }
                UISelectionFeedbackGenerator().selectionChanged()
                self.router.presentPayment(for: transaction, from: viewController)
            }
        case .failure(let error):
            scanLog.error("didCaptureCode: parse failed \(String(describing: error), privacy: .public)")
            // Throttle error alerts so a bad QR doesn't spam the user.
            let now = Date()
            if let last = lastErrorAt, now.timeIntervalSince(last) < 2 {
                scanLog.info("didCaptureCode: error throttled")
                return
            }
            lastErrorAt = now
            DispatchQueue.main.async { [weak self] in
                self?.view?.showError(
                    ScanError.invalidQR(error).userMessage,
                    allowsSettings: false,
                    retryable: true
                )
            }
        }
    }

    func didTapPickFromGallery() {
        // Out of scope for this demo — keep the button as a placeholder for a future
        // gallery-import flow without wiring up PhotosUI.
    }

    func didTapBack() {
        view?.stopCameraSession()
    }

    func didConfirmSettingsAlert() {
        router.openSystemSettings()
    }
}
