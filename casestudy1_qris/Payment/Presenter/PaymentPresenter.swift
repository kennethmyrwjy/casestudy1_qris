import UIKit

protocol PaymentPresenting: AnyObject {
    func viewDidLoad()
    func didTapPay()
    func didTapBack()
}

protocol PaymentConfirmationViewControlling: AnyObject {
    func render(_ viewModel: PaymentConfirmationViewModel)
    func setLoading(_ loading: Bool)
    func showError(_ message: String)
}

final class PaymentPresenter: PaymentPresenting {

    private weak var view: PaymentConfirmationViewControlling?
    private let interactor: PaymentInteracting
    private let router: PaymentRouting
    private let transaction: QRISTransaction
    private var isProcessing = false
    private var userRepository: UserRepository

    init(
        view: PaymentConfirmationViewControlling,
        interactor: PaymentInteracting,
        router: PaymentRouting,
        transaction: QRISTransaction,
        userRepository: UserRepository
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.transaction = transaction
        self.userRepository = userRepository
    }

    func viewDidLoad() {
        view?.render(makeViewModel())
    }

    func didTapPay() {
        guard !isProcessing else { return }
        isProcessing = true
        view?.setLoading(true)

        Task { [weak self] in
            guard let self else { return }
            let result = await self.interactor.executePayment(self.transaction)
            await MainActor.run {
                self.view?.setLoading(false)
                self.isProcessing = false
                switch result {
                case .success(let receipt):
                    guard let viewController = self.view as? UIViewController else { return }
                    self.router.presentSuccess(
                        transaction: self.transaction,
                        receipt: receipt,
                        from: viewController
                    )
                case .failure(let error):
                    self.view?.showError(self.message(for: error))
                }
            }
        }
    }

    func didTapBack() {}
    
//    why fetch data in makeViewModel? if user updates profile, data in view is updated immediately, rather than init storing stale data
    private func makeViewModel() -> PaymentConfirmationViewModel {
        let user = userRepository.currentUser()
        return PaymentConfirmationViewModel(
            merchantName: transaction.merchantName.capitalizedDisplay,
            merchantLocation: "Jakarta, Indonesia",
            sourceAccountHolder: user.fullName,
            sourceAccountType: user.accountType,
            sourceAccountNumber: user.accountNumber,
            amount: transaction.amount,
            formattedAmount: CurrencyFormatter.format(transaction.amount)
        )
    }

    private func message(for error: Error) -> String {
        if let balanceError = error as? BalanceError {
            switch balanceError {
            case .insufficientFunds:
                return "Saldo tidak mencukupi."
            }
        }
        if let paymentError = error as? PaymentError {
            switch paymentError {
            case .network: return "Koneksi gagal. Silakan coba lagi."
            case .declined(let reason): return "Pembayaran ditolak: \(reason)"
            }
        }
        return "Terjadi kesalahan tak terduga. Silakan coba lagi."
    }
}

private extension String {
    /// Reference UI shows merchant names in title-case ("Family Mart") even when the
    /// QR encodes them as ALL CAPS. Cheap normalization.
    var capitalizedDisplay: String {
        let lower = lowercased()
        return lower.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }
}
