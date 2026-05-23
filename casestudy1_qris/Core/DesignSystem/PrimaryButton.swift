import UIKit

/// The pill-shaped teal CTA used across the reference app (Lanjut, Bayar Sekarang).
final class PrimaryButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)
        configure(title: title)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = DesignSystem.Color.primary
        config.baseForegroundColor = .black
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24)
        var titleAttr = AttributeContainer()
        titleAttr.font = DesignSystem.Typography.button()
        config.attributedTitle = AttributedString(title, attributes: titleAttr)
        configuration = config

        accessibilityTraits = .button
        isAccessibilityElement = true
    }

    func setEnabledState(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }
}
