import UIKit
import SnapKit

final class HomeViewController: UIViewController, HomeViewControlling {

    var presenter: HomePresenting?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let greetingLabel = UILabel()
//    private let fullNameLabel = UILabel()
//    private let accountSummaryLabel = UILabel()
    private let accountTypeLabel = UILabel()
    private let accountNumberLabel = UILabel()
    private let balanceCard = CardView(style: .tinted)
    private let balanceTitleLabel = UILabel()
    private let balanceValueLabel = UILabel()
    private let eyeButton = UIButton(type: .system)

    private let historyButton = HistoryRowButton()
    private let qrisButton = FloatingQRISButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.Color.surface
        title = "Beranda"
        navigationController?.navigationBar.prefersLargeTitles = false
        setupViews()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    private func setupViews() {
        greetingLabel.font = DesignSystem.Typography.greeting()
        greetingLabel.textColor = DesignSystem.Color.textPrimary
        greetingLabel.adjustsFontForContentSizeCategory = true

//        fullNameLabel.font = DesignSystem.Typography.bodyBold()
//        fullNameLabel.textColor = DesignSystem.Color.textPrimary
//        fullNameLabel.adjustsFontForContentSizeCategory = true
        
//        accountSummaryLabel.font = DesignSystem.Typography.caption()
//        accountSummaryLabel.textColor = DesignSystem.Color.textSecondary
//        accountSummaryLabel.adjustsFontForContentSizeCategory = true
        
        accountTypeLabel.font = DesignSystem.Typography.accountType()
        accountTypeLabel.textColor = DesignSystem.Color.textPrimary
        accountTypeLabel.adjustsFontForContentSizeCategory = true
        
        accountNumberLabel.font = DesignSystem.Typography.accountNumber()
        accountNumberLabel.textColor = DesignSystem.Color.textPrimary
        accountNumberLabel.adjustsFontForContentSizeCategory = true
        
        balanceTitleLabel.text = "Saldo"
        balanceTitleLabel.font = DesignSystem.Typography.bodyBold()
        balanceTitleLabel.textColor = DesignSystem.Color.textPrimary

        balanceValueLabel.font = DesignSystem.Typography.amount()
        balanceValueLabel.textColor = DesignSystem.Color.textPrimary
        balanceValueLabel.adjustsFontForContentSizeCategory = true
        balanceValueLabel.accessibilityIdentifier = "home.balance"
        balanceValueLabel.isUserInteractionEnabled = true
        balanceValueLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapEye))
        )

        let eyeConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        eyeButton.setImage(UIImage(systemName: "eye", withConfiguration: eyeConfig), for: .normal)
        eyeButton.tintColor = DesignSystem.Color.textPrimary
        eyeButton.addTarget(self, action: #selector(didTapEye), for: .touchUpInside)
        eyeButton.accessibilityLabel = "Sembunyikan saldo"

        historyButton.addTarget(self, action: #selector(didTapHistory), for: .touchUpInside)
        qrisButton.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(greetingLabel)
        contentView.addSubview(balanceCard)
//        balanceCard.addSubview(fullNameLabel)
//        balanceCard.addSubview(accountSummaryLabel)
        balanceCard.addSubview(accountTypeLabel)
        balanceCard.addSubview(accountNumberLabel)
        balanceCard.addSubview(balanceTitleLabel)
        balanceCard.addSubview(balanceValueLabel)
        balanceCard.addSubview(eyeButton)
        contentView.addSubview(historyButton)
        // qrisButton sits OUTSIDE the scroll view so it stays pinned to the bottom
        // regardless of scroll position.
        view.addSubview(qrisButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        greetingLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        balanceCard.snp.makeConstraints { make in
            make.top.equalTo(greetingLabel.snp.bottom).offset(DesignSystem.Spacing.sm)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
//        fullNameLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
//            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
//        }
//        accountSummaryLabel.snp.makeConstraints { make in
//            make.top.equalTo(fullNameLabel.snp.bottom).offset(DesignSystem.Spacing.xxs)
//            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
//        }
        accountTypeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        accountNumberLabel.snp.makeConstraints{ make in
            make.top.equalTo(accountTypeLabel.snp.bottom).offset(DesignSystem.Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        balanceTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(accountNumberLabel.snp.bottom).offset(DesignSystem.Spacing.md)
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.md)
        }
        balanceValueLabel.snp.makeConstraints { make in
            make.top.equalTo(balanceTitleLabel.snp.bottom).offset(DesignSystem.Spacing.xxs)
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.trailing.lessThanOrEqualTo(eyeButton.snp.leading).offset(-DesignSystem.Spacing.sm)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        eyeButton.snp.makeConstraints { make in
            make.centerY.equalTo(balanceValueLabel)
            make.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
            make.width.equalTo(28)
            make.height.equalTo(20)
        }
        historyButton.snp.makeConstraints { make in
            make.top.equalTo(balanceCard.snp.bottom).offset(DesignSystem.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.xl)
        }
        qrisButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(DesignSystem.Spacing.lg)
            make.height.equalTo(56)
            make.width.equalTo(140)
        }
    }

    @objc private func didTapScan() { presenter?.didTapScan() }
    @objc private func didTapHistory() { presenter?.didTapHistory() }
    @objc private func didTapEye() { presenter?.didToggleSensitiveDataVisibility() }

    func render(_ viewModel: HomeViewModel) {
        greetingLabel.text = viewModel.greeting
        accountTypeLabel.text = viewModel.accountType
        accountNumberLabel.text = viewModel.formattedAccountNumber
        balanceValueLabel.text = viewModel.formattedBalance
        balanceValueLabel.accessibilityLabel = viewModel.isSensitiveDataHidden
            ? "Saldo disembunyikan"
            : "Saldo \(viewModel.formattedBalance)"
        let iconName = viewModel.isSensitiveDataHidden ? "eye.slash" : "eye"
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        eyeButton.setImage(UIImage(systemName: iconName, withConfiguration: config), for: .normal)
        eyeButton.accessibilityLabel = viewModel.isSensitiveDataHidden ? "Tampilkan saldo" : "Sembunyikan saldo"
    }
}
