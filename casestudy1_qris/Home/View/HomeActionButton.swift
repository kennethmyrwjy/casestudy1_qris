import UIKit
import SnapKit

/// Full-width rectangular Riwayat entry: icon on tinted bubble, title, subtitle,
/// chevron. Replaces the previous side-by-side tile layout now that Scan moved to
/// a floating QRIS pill at the bottom of Home.
final class HistoryRowButton: UIControl {

    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let chevron = UIImageView()

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.alpha = self.isHighlighted ? 0.6 : 1.0
            }
        }
    }

    private func configure() {
        backgroundColor = DesignSystem.Color.surface
        layer.cornerRadius = DesignSystem.Radius.card
        layer.borderWidth = 1
        layer.borderColor = DesignSystem.Color.secondary.cgColor

        iconBackground.backgroundColor = DesignSystem.Color.secondary.withAlphaComponent(0.18)
        iconBackground.layer.cornerRadius = 20

        iconView.image = UIImage(
            systemName: "clock.arrow.circlepath",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        )
        iconView.tintColor = DesignSystem.Color.secondary
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = "Riwayat Transaksi"
        titleLabel.font = DesignSystem.Typography.titlesub()
        titleLabel.textColor = DesignSystem.Color.textPrimary
        titleLabel.adjustsFontForContentSizeCategory = true

        subtitleLabel.text = "Lihat transaksi sebelumnya"
        subtitleLabel.font = DesignSystem.Typography.sectionHeader()
        subtitleLabel.textColor = DesignSystem.Color.textSecondary
        subtitleLabel.adjustsFontForContentSizeCategory = true

        chevron.image = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        )
        chevron.tintColor = DesignSystem.Color.textTertiary
        chevron.contentMode = .scaleAspectFit

        addSubview(iconBackground)
        iconBackground.addSubview(iconView)
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(chevron)

        iconBackground.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
            make.top.bottom.lessThanOrEqualToSuperview().inset(DesignSystem.Spacing.md)
        }
        iconView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        chevron.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
            make.centerY.equalToSuperview()
            make.width.equalTo(10)
            make.height.equalTo(16)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.equalTo(iconBackground.snp.trailing).offset(DesignSystem.Spacing.sm)
            make.trailing.lessThanOrEqualTo(chevron.snp.leading).offset(-DesignSystem.Spacing.sm)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(chevron.snp.leading).offset(-DesignSystem.Spacing.sm)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }

        isAccessibilityElement = true
        accessibilityLabel = "Riwayat Transaksi, lihat transaksi sebelumnya"
        accessibilityTraits = .button
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.borderColor = DesignSystem.Color.secondary.cgColor
    }
}

/// Floating QRIS button anchored at the bottom-center of Home. Adapts to light/dark:
/// black pill + white logo in light mode, white pill + black logo in dark mode.
/// A subtle highlight gradient + drop shadow gives it a 3D "bulge" appearance so
/// it reads as a tappable button floating above the content.
final class FloatingQRISButton: UIControl {

    private let logoView = UIImageView()
    private let highlightLayer = CAGradientLayer()
    private let innerShadowLayer = CAGradientLayer()

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
                self.alpha = self.isHighlighted ? 0.9 : 1.0
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = bounds.height / 2
        layer.cornerRadius = radius
        highlightLayer.frame = bounds
        highlightLayer.cornerRadius = radius
        innerShadowLayer.frame = bounds
        innerShadowLayer.cornerRadius = radius
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        applyAdaptiveStyling()
    }

    private func configure() {
        clipsToBounds = false

        // Soft drop shadow underneath the pill — the foundation of the floating feel.
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowRadius = 14
        layer.shadowOffset = CGSize(width: 0, height: 6)

        // Top highlight gradient — fakes a light source hitting the top of the pill.
        highlightLayer.colors = [
            UIColor.white.withAlphaComponent(0.22).cgColor,
            UIColor.white.withAlphaComponent(0.0).cgColor
        ]
        highlightLayer.locations = [0.0, 0.55]
        highlightLayer.startPoint = CGPoint(x: 0.5, y: 0)
        highlightLayer.endPoint = CGPoint(x: 0.5, y: 1)
        highlightLayer.masksToBounds = true
        layer.addSublayer(highlightLayer)

        // Subtle bottom darkening — reinforces the 3D dome by darkening the underside.
        innerShadowLayer.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.18).cgColor
        ]
        innerShadowLayer.locations = [0.55, 1.0]
        innerShadowLayer.startPoint = CGPoint(x: 0.5, y: 0)
        innerShadowLayer.endPoint = CGPoint(x: 0.5, y: 1)
        innerShadowLayer.masksToBounds = true
        layer.addSublayer(innerShadowLayer)

        logoView.contentMode = .scaleAspectFit
        addSubview(logoView)
        logoView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.45)
            make.width.lessThanOrEqualToSuperview().inset(DesignSystem.Spacing.md)
        }

        applyAdaptiveStyling()

        isAccessibilityElement = true
        accessibilityLabel = "Pindai QRIS"
        accessibilityHint = "Buka pemindai kode QRIS untuk membayar"
        accessibilityTraits = .button
    }

    private func applyAdaptiveStyling() {
        let isDark = traitCollection.userInterfaceStyle == .dark
        backgroundColor = isDark ? .white : .black
        logoView.image = UIImage(named: isDark ? "qris-logo-black" : "qris-logo-white")
        // Swap the highlight/shadow polarity too — on a white pill the highlight
        // should be subtle and the underside slightly darker; on black, the opposite.
        if isDark {
            highlightLayer.colors = [
                UIColor.white.withAlphaComponent(0.0).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ]
            innerShadowLayer.colors = [
                UIColor.black.withAlphaComponent(0.0).cgColor,
                UIColor.black.withAlphaComponent(0.10).cgColor
            ]
        } else {
            highlightLayer.colors = [
                UIColor.white.withAlphaComponent(0.22).cgColor,
                UIColor.white.withAlphaComponent(0.0).cgColor
            ]
            innerShadowLayer.colors = [
                UIColor.black.withAlphaComponent(0.0).cgColor,
                UIColor.black.withAlphaComponent(0.18).cgColor
            ]
        }
    }
}
