import UIKit
import AVFoundation
import OSLog
import SnapKit

private let scanLog = Logger(subsystem: "com.example.casestudy1-qris", category: "Scan")

final class ScanViewController: UIViewController, ScanViewControlling {

    var presenter: ScanPresenting?

    private let captureSession = AVCaptureSession()
    private let metadataQueue = DispatchQueue(label: "qris.scan.metadata", qos: .userInitiated)
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    private var metadataDelegateBridge: MetadataDelegateBridge?
    private var didConfigureSession = false

    private let cameraContainer = UIView()
    private let viewfinderOverlay = ViewfinderOverlayView()
    private let promptLabel = UILabel()
    private let qrisBadge = QRISBadgeView()
    private let bottomBar = UIView()
    private let permissionView = CameraPermissionView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigationBar()
        setupViews()
        configureCaptureSession()
        presenter?.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = cameraContainer.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter?.viewWillDisappear()
    }

    private func setupNavigationBar() {
        title = nil
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        let back = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(didTapBack)
        )
        navigationItem.leftBarButtonItem = back
        navigationItem.titleView = qrisBadge
    }

    private func setupViews() {
        cameraContainer.backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        cameraContainer.layer.addSublayer(previewLayer)

        viewfinderOverlay.backgroundColor = .clear
        viewfinderOverlay.isUserInteractionEnabled = false

        promptLabel.text = "Posisikan kode QR di dalam bingkai"
        promptLabel.textColor = .white
        promptLabel.font = DesignSystem.Typography.body()
        promptLabel.textAlignment = .center
        promptLabel.adjustsFontForContentSizeCategory = true
        promptLabel.numberOfLines = 0

        bottomBar.backgroundColor = .black

        view.addSubview(cameraContainer)
        view.addSubview(viewfinderOverlay)
        view.addSubview(promptLabel)
        view.addSubview(bottomBar)
        view.addSubview(permissionView)
        permissionView.isHidden = true
        permissionView.onTapOpenSettings = { [weak self] in
            self?.presenter?.didConfirmSettingsAlert()
        }

        cameraContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewfinderOverlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        promptLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(DesignSystem.Spacing.xxl)
        }
        bottomBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        permissionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - AVFoundation

    private func configureCaptureSession() {
        guard !didConfigureSession else {
            scanLog.info("configureCaptureSession skipped — already configured")
            return
        }
        didConfigureSession = true

        // All configuration happens off the main thread so we never block UI.
        metadataQueue.async { [weak self] in
            guard let self else { return }
            scanLog.info("configureCaptureSession: starting on \(Thread.current)")
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .high

            guard let device = AVCaptureDevice.default(for: .video) else {
                scanLog.error("configureCaptureSession: AVCaptureDevice.default returned nil")
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.showError(ScanError.cameraUnavailable.userMessage, allowsSettings: false, retryable: false)
                }
                return
            }
            scanLog.info("configureCaptureSession: device=\(device.localizedName, privacy: .public)")

            let input: AVCaptureDeviceInput
            do {
                input = try AVCaptureDeviceInput(device: device)
            } catch {
                scanLog.error("configureCaptureSession: AVCaptureDeviceInput failed: \(error.localizedDescription, privacy: .public)")
                self.captureSession.commitConfiguration()
                DispatchQueue.main.async {
                    self.showError(ScanError.cameraUnavailable.userMessage, allowsSettings: false, retryable: false)
                }
                return
            }
            guard self.captureSession.canAddInput(input) else {
                scanLog.error("configureCaptureSession: canAddInput returned false")
                self.captureSession.commitConfiguration()
                return
            }
            self.captureSession.addInput(input)

            let output = AVCaptureMetadataOutput()
            guard self.captureSession.canAddOutput(output) else {
                scanLog.error("configureCaptureSession: canAddOutput returned false")
                self.captureSession.commitConfiguration()
                return
            }
            self.captureSession.addOutput(output)
            let bridge = MetadataDelegateBridge { [weak self] code in
                scanLog.info("metadata bridge fired with code length=\(code.count)")
                self?.presenter?.didCaptureCode(code)
            }
            output.setMetadataObjectsDelegate(bridge, queue: self.metadataQueue)
            self.metadataDelegateBridge = bridge

            // metadataObjectTypes MUST be set AFTER addOutput, otherwise it's empty.
            let supported = output.availableMetadataObjectTypes
            scanLog.info("configureCaptureSession: availableMetadataObjectTypes=\(supported.map(\.rawValue), privacy: .public)")
            if supported.contains(.qr) {
                output.metadataObjectTypes = [.qr]
                scanLog.info("configureCaptureSession: registered .qr metadata type")
            } else {
                scanLog.error("configureCaptureSession: .qr NOT in supported types")
            }

            self.captureSession.commitConfiguration()
            scanLog.info("configureCaptureSession: committed")

            DispatchQueue.main.async {
                self.setTorchAvailable(device.hasTorch)
            }
        }
    }

    // MARK: - ScanViewControlling

    func startCameraSession() {
        scanLog.info("startCameraSession: requested")
        ensureCameraAuthorized { [weak self] granted in
            guard let self else { return }
            scanLog.info("startCameraSession: permission granted=\(granted)")
            guard granted else {
                self.showPermissionEmptyState()
                return
            }
            self.hidePermissionEmptyState()
            self.metadataQueue.async {
                if !self.captureSession.isRunning {
                    scanLog.info("startCameraSession: calling startRunning")
                    self.captureSession.startRunning()
                    scanLog.info("startCameraSession: isRunning=\(self.captureSession.isRunning)")
                } else {
                    scanLog.info("startCameraSession: already running")
                }
            }
        }
    }

    func stopCameraSession() {
        metadataQueue.async { [weak self] in
            guard let self else { return }
            if self.captureSession.isRunning {
                scanLog.info("stopCameraSession: calling stopRunning")
                self.captureSession.stopRunning()
            }
        }
    }

    private func showPermissionEmptyState() {
        permissionView.isHidden = false
        cameraContainer.isHidden = true
        viewfinderOverlay.isHidden = true
        navigationItem.titleView = nil
        promptLabel.isHidden = true
        view.backgroundColor = DesignSystem.Color.surface
        // Restore nav bar to light styling for the empty state.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = DesignSystem.Color.textPrimary
    }

    private func hidePermissionEmptyState() {
        guard !permissionView.isHidden else {
            permissionView.isHidden = true
            cameraContainer.isHidden = false
            viewfinderOverlay.isHidden = false
            navigationItem.titleView = qrisBadge
            promptLabel.isHidden = false
            view.backgroundColor = .black
            setupNavigationBar()
            return
        }
    }

    func showError(_ message: String, allowsSettings: Bool, retryable: Bool) {
        let alert = UIAlertController(title: "Tidak Dapat Memindai", message: message, preferredStyle: .alert)
        if allowsSettings {
            alert.addAction(UIAlertAction(title: "Buka Pengaturan", style: .default) { [weak self] _ in
                self?.presenter?.didConfirmSettingsAlert()
            })
        }
        if retryable {
            alert.addAction(UIAlertAction(title: "Coba Lagi", style: .default))
        }
        alert.addAction(UIAlertAction(title: "Kembali", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    func setTorchAvailable(_ available: Bool) {
        // Hook left in place — UI control intentionally omitted to keep the surface lean.
    }

    @objc private func didTapBack() {
        presenter?.didTapBack()
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Permission

    private func ensureCameraAuthorized(_ completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}

private extension ScanError {
    func localizedMessage() -> String { userMessage }
}

private final class MetadataDelegateBridge: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    private let onCode: (String) -> Void

    init(onCode: @escaping (String) -> Void) {
        self.onCode = onCode
    }

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        scanLog.info("metadataOutput: \(metadataObjects.count) objects")
        for object in metadataObjects {
            guard let readable = object as? AVMetadataMachineReadableCodeObject else {
                scanLog.info("metadataOutput: object is not AVMetadataMachineReadableCodeObject")
                continue
            }
            scanLog.info("metadataOutput: type=\(readable.type.rawValue, privacy: .public)")
            guard readable.type == .qr, let value = readable.stringValue else {
                continue
            }
            scanLog.info("metadataOutput: QR value=\(value, privacy: .public)")
            onCode(value)
            return
        }
    }
}
