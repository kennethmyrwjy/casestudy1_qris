import UIKit
import SnapKit

final class InfoBanner: UIView {

    private let iconView = UIImageView()
    private let messageLabel = UILabel()

    init(message: String) {
        super.init(frame: .zero)
        configure(message: message)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure(message: String) {
        backgroundColor = DesignSystem.Color.secondaryOpaque
        layer.cornerRadius = 10

        iconView.image = UIImage(
            systemName: "info.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        )
        iconView.tintColor = DesignSystem.Color.secondary
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)

        messageLabel.text = message
        messageLabel.font = DesignSystem.Typography.caption()
        messageLabel.textColor = DesignSystem.Color.textPrimary
        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true

        addSubview(iconView)
        addSubview(messageLabel)

        iconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.sm)
//            make.top.equalToSuperview().offset(DesignSystem.Spacing.sm)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconView.snp.trailing).offset(DesignSystem.Spacing.xs)
            make.trailing.equalToSuperview().inset(DesignSystem.Spacing.sm)
            make.top.equalToSuperview().offset(DesignSystem.Spacing.sm)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.sm)
        }

        isAccessibilityElement = true
        accessibilityLabel = message
        accessibilityTraits.insert(.staticText)
    }
}

#Preview("Normal") {
    InfoBanner(message: "Test")
}

#Preview("Long") {
    InfoBanner(message: "This is a test message to see the info banner with a longer message that forces it to multiple line.")
}
