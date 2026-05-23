import UIKit

protocol HomeRouting: AnyObject {
    func presentScan(from view: UIViewController)
    func presentHistory(from view: UIViewController)
}

final class HomeRouter: HomeRouting {

    static func build() -> UIViewController {
        let view = HomeViewController()
        let router = HomeRouter()
        let interactor = HomeInteractor(
            balanceRepository: AppDependencies.shared.balanceRepository,
            transactionRepository: AppDependencies.shared.transactionRepository, userRepository: AppDependencies.shared.userRepository
        )
        let presenter = HomePresenter(view: view, interactor: interactor, router: router)
        view.presenter = presenter
        return view
    }

    func presentScan(from view: UIViewController) {
        let scan = ScanRouter.build()
        scan.hidesBottomBarWhenPushed = true
        view.navigationController?.pushViewController(scan, animated: true)
    }

    func presentHistory(from view: UIViewController) {
        let history = HistoryRouter.build()
        view.navigationController?.pushViewController(history, animated: true)
    }
}
