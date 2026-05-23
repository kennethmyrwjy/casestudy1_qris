import UIKit

protocol HistoryRouting: AnyObject {
    func presentTransactionDetail(_ record: PaymentRecord, from view: UIViewController)
}

final class HistoryRouter: HistoryRouting {

    static func build() -> UIViewController {
        let view = HistoryViewController()
        let router = HistoryRouter()
        let interactor = HistoryInteractor(repository: AppDependencies.shared.transactionRepository)
        let presenter = HistoryPresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }

    func presentTransactionDetail(_ record: PaymentRecord, from view: UIViewController) {
        let context = PaymentSuccessContext(from: record, userProfile: AppDependencies.shared.userRepository.currentUser())
        // onReturnHome is a no-op in history-detail mode (the CTA is hidden), but
        // the closure parameter is non-optional so we pass a noop.
        let detail = PaymentSuccessViewController(context: context, onReturnHome: {})
        view.navigationController?.pushViewController(detail, animated: true)
    }
}
