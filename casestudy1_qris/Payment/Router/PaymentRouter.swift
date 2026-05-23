import UIKit

protocol PaymentRouting: AnyObject {
    func presentSuccess(transaction: QRISTransaction, receipt: PaymentReceipt, from view: UIViewController)
    func returnToHome(from view: UIViewController)
}

final class PaymentRouter: PaymentRouting {

    static func build(transaction: QRISTransaction) -> UIViewController {
        let view = PaymentConfirmationViewController()
        let router = PaymentRouter()
        let interactor = PaymentInteractor(
            balanceRepository: AppDependencies.shared.balanceRepository,
            executionService: AppDependencies.shared.paymentExecutionService
        )
        let presenter = PaymentPresenter(
            view: view,
            interactor: interactor,
            router: router,
            transaction: transaction,
            userRepository: AppDependencies.shared.userRepository
//            dependency injection, presenter can be handed fake data for testing
        )
        view.presenter = presenter
        return view
    }

    func presentSuccess(transaction: QRISTransaction, receipt: PaymentReceipt, from view: UIViewController) {
        let context = PaymentSuccessContext(from: transaction, receipt: receipt, userProfile: AppDependencies.shared.userRepository.currentUser())
        let success = PaymentSuccessViewController(context: context) { [weak view] in
            guard let view else { return }
            self.returnToHome(from: view)
        }
        success.modalPresentationStyle = .fullScreen
        view.navigationController?.pushViewController(success, animated: true)
    }

    func returnToHome(from view: UIViewController) {
        view.navigationController?.popToRootViewController(animated: true)
    }
}
