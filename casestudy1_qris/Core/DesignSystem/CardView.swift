import UIKit

/// Soft outlined rounded container — the recurring card pattern in the reference UI.
final class CardView: UIView {
    
    enum Style {
        case plain // white system background
        case tinted // orange tint background
    }
    
    init(style: Style = .plain) {
        super.init(frame: .zero)
        layer.cornerRadius = DesignSystem.Radius.card
        apply(style: style)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func apply(style: Style) {
        switch style {
        case .plain:
            backgroundColor = DesignSystem.Color.cardBackground
            layer.borderWidth = 1
            layer.borderColor = DesignSystem.Color.cardBorder.cgColor
        case .tinted:
            backgroundColor = DesignSystem.Color.secondary.withAlphaComponent(1)
            layer.borderWidth = 0
            layer.borderColor = DesignSystem.Color.secondary.cgColor
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = DesignSystem.Color.cardBorder.cgColor
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

#Preview("Long Name") {
    let view = HomeViewController()
    let interactor = PreviewHomeInteractor()
    interactor.userProfile = UserProfile(fullName: "Abdurrahman", accountType: "Taplus Muda", accountNumber: "0674646333")
    let router = PreviewHomeRouter()
    let presenter = HomePresenter(view: view, interactor: interactor, router: router)
    view.presenter = presenter
    return UINavigationController(rootViewController: view)
}

#endif
