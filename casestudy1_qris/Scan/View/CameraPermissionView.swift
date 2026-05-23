import UIKit
import SnapKit

/// Full-screen empty state shown when the user has previously denied camera access.
/// Replaces the modal alert with an inline experience matching what production
/// banking apps do (Apple Wallet, Jago, BCA mobile, etc.).
final class CameraPermissionView: UIView {

    var onTapOpenSettings: (() -> Void)?

    private let iconBackground = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let settingsButton = PrimaryButton(title: "Buka Pengaturan")

    init() {
        super.init(frame: .zero)
        backgroundColor = DesignSystem.Color.surface
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        iconBackground.backgroundColor = DesignSystem.Color.primary.withAlphaComponent(0.18)
        iconBackground.layer.cornerRadius = 40

        iconView.image = UIImage(
            systemName: "camera.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .semibold)
        )
        iconView.tintColor = DesignSystem.Color.primaryText
        iconView.contentMode = .scaleAspectFit

        titleLabel.text = "Izin Kamera Diperlukan"
        titleLabel.font = DesignSystem.Typography.successTitle()
        titleLabel.textColor = DesignSystem.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.accessibilityTraits.insert(.header)

        bodyLabel.text = "Untuk memindai kode QRIS, aplikasi memerlukan akses ke kamera. Aktifkan izin di Pengaturan untuk melanjutkan."
        bodyLabel.font = DesignSystem.Typography.body()
        bodyLabel.textColor = DesignSystem.Color.textSecondary
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        settingsButton.addTarget(self, action: #selector(didTapSettings), for: .touchUpInside)

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.axis = .vertical
        textStack.spacing = DesignSystem.Spacing.sm
        textStack.alignment = .fill

        addSubview(iconBackground)
        iconBackground.addSubview(iconView)
        addSubview(textStack)
        addSubview(settingsButton)

        iconBackground.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-DesignSystem.Spacing.xxl)
            make.width.height.equalTo(80)
        }
        iconView.snp.makeConstraints { make in make.center.equalToSuperview() }
        textStack.snp.makeConstraints { make in
            make.top.equalTo(iconBackground.snp.bottom).offset(DesignSystem.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.xl)
        }
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(textStack.snp.bottom).offset(DesignSystem.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.height.equalTo(56)
        }
    }

    @objc private func didTapSettings() {
        onTapOpenSettings?()
    }
}
