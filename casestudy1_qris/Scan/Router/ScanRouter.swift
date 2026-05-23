import UIKit

protocol ScanRouting: AnyObject {
    func presentPayment(for transaction: QRISTransaction, from view: UIViewController)
    func openSystemSettings()
}

final class ScanRouter: ScanRouting {

    static func build() -> UIViewController {
        let view = ScanViewController()
        let router = ScanRouter()
        let interactor = ScanInteractor(parser: AppDependencies.shared.qrParser)
        let presenter = ScanPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }

    func presentPayment(for transaction: QRISTransaction, from view: UIViewController) {
        let payment = PaymentRouter.build(transaction: transaction)
        view.navigationController?.pushViewController(payment, animated: true)
    }

    func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
