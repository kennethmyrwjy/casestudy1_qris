import UIKit

// name not consistent due to pivot
enum RootTabBarBuilder {

    static func make() -> UIViewController {
        let nav = UINavigationController(rootViewController: HomeRouter.build())
        nav.navigationBar.tintColor = DesignSystem.Color.textPrimary
        return nav
    }
}
