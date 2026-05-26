import UIKit

enum DesignSystem {

    enum Color {
        static let primary = UIColor(red: 0.498, green: 0.827, blue: 0.769, alpha: 1.0)      // #7FD3C4 teal CTA
        static let primaryText = UIColor(red: 0.067, green: 0.275, blue: 0.247, alpha: 1.0)  // dark teal for "FM" badge etc.
        static let secondary = UIColor(red: 0.937, green: 0.502, blue: 0.243, alpha: 1.0)    // #EF803E orange chip
        static let secondaryOpaque = UIColor(red: 0.937, green: 0.502, blue: 0.243, alpha: 0.18)
        static let textPrimary = UIColor.label
        static let textSecondary = UIColor.secondaryLabel
        static let textTertiary = UIColor.tertiaryLabel
        static let cardBorder = UIColor.separator.withAlphaComponent(0.3)
        static let cardBackground = UIColor.systemBackground
        static let surface = UIColor.systemBackground
        static let surfaceMuted = UIColor.secondarySystemBackground
        static let success = UIColor.systemGreen
        static let danger = UIColor.systemRed
    }

    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let card: CGFloat = 12
        static let button: CGFloat = 28
        static let chip: CGFloat = 16
    }
// for consistency and accessibility larger text
    enum Typography {
        static func greeting() -> UIFont {
            UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 24, weight: .bold))
        }
        static func accountType() -> UIFont {
            UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 17, weight: .semibold))
        }
        static func accountNumber() -> UIFont {
            UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 22, weight: .bold))
        }
        static func balanceHero() -> UIFont {
            UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 40, weight: .heavy))
        }
        static func title() -> UIFont {
            UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 22, weight: .bold))
        }
        static func titlesub() -> UIFont {
            UIFontMetrics(forTextStyle: .title2).scaledFont(for: .systemFont(ofSize: 17, weight: .bold))
        }
        static func sectionHeader() -> UIFont {
            UIFontMetrics(forTextStyle: .subheadline).scaledFont(for: .systemFont(ofSize: 13, weight: .semibold))
        }
        static func body() -> UIFont {
            UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .regular))
        }
        static func bodyBold() -> UIFont {
            UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        }
        static func amount() -> UIFont {
            UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 32, weight: .bold))
        }
        static func amountLarge() -> UIFont {
            UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: .systemFont(ofSize: 36, weight: .heavy))
        }
        static func successTitle() -> UIFont {
            UIFontMetrics(forTextStyle: .title3).scaledFont(for: .systemFont(ofSize: 20, weight: .semibold))
        }
        static func caption() -> UIFont {
            UIFontMetrics(forTextStyle: .caption1).scaledFont(for: .systemFont(ofSize: 12, weight: .regular))
        }
        static func button() -> UIFont {
            UIFontMetrics(forTextStyle: .body).scaledFont(for: .systemFont(ofSize: 16, weight: .semibold))
        }
    }
}
