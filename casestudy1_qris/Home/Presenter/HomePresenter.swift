import UIKit

protocol HomePresenting: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func didTapScan()
    func didTapHistory()
    func didToggleSensitiveDataVisibility()
}

protocol HomeViewControlling: AnyObject {
    func render(_ viewModel: HomeViewModel)
}

final class HomePresenter: HomePresenting {

    private weak var view: HomeViewControlling?
    private let interactor: HomeInteracting
    private let router: HomeRouting
    private var isSensitiveDataHidden = true

    init(view: HomeViewControlling, interactor: HomeInteracting, router: HomeRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() { render() }
    func viewWillAppear() { render() }

    func didTapScan() {
        guard let viewController = view as? UIViewController else { return }
        router.presentScan(from: viewController)
    }

    func didTapHistory() {
        guard let viewController = view as? UIViewController else { return }
        router.presentHistory(from: viewController)
    }

    func didToggleSensitiveDataVisibility() {
        isSensitiveDataHidden.toggle()
        render()
    }

    private func render() {
        let balance = interactor.fetchBalance()
        let user = interactor.currentUser()
        
        let formattedBalance = isSensitiveDataHidden ? "Rp•••••••" : CurrencyFormatter.format(balance)
        let formattedAccountNumber = isSensitiveDataHidden ? "•••••••" + user.accountNumber.suffix(3) : user.accountNumber
        view?.render(HomeViewModel(
            formattedBalance: formattedBalance,
            greeting: "Hi, \(user.firstName)!",
            isSensitiveDataHidden: isSensitiveDataHidden,
            accountType: user.accountType,
            formattedAccountNumber: formattedAccountNumber
        ))
    }
}

#if DEBUG
private final class PreviewHomeInteractor: HomeInteracting {
    var balance = 1500000
    var userProfile = UserProfile(fullName: "Kenneth Mayer Wijaya", accountType: "Taplus Muda", accountNumber: "0674646111")
    var transactionCount = 3
    
    func fetchBalance() -> Int { balance }
    func recentTransactionCount() -> Int { transactionCount }
    func currentUser() -> UserProfile { userProfile }
}

private final class PreviewHomeRouter: HomeRouting {
    func presentScan(from view: UIViewController) {}
    func presentHistory(from view: UIViewController) {}
}

#Preview("Default") {
    let view = HomeViewController()
    let interactor = PreviewHomeInteractor()
//    interactor.userProfile = UserProfile(fullName: "Kenneth Mayer Wijaya", accountType: "Taplus Muda", accountNumber: "0674646111")
    let router = PreviewHomeRouter()
    let presenter = HomePresenter(view: view, interactor: interactor, router: router)
    view.presenter = presenter
    return UINavigationController(rootViewController: view)
}

#endif
