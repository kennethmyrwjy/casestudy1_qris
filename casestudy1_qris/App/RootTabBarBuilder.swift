import UIKit

/// Builds the root view controller. We use a single navigation controller rooted at
/// Home — the design moved away from a bottom tab bar in favor of a floating QRIS
/// action on Home and an inline Riwayat entry, matching the reference banking app.
enum RootTabBarBuilder {

    static func make() -> UIViewController {
        let nav = UINavigationController(rootViewController: HomeRouter.build())
        nav.navigationBar.tintColor = DesignSystem.Color.textPrimary
        return nav
    }
}
