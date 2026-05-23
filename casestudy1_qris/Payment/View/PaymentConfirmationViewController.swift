import UIKit
import SnapKit

final class PaymentConfirmationViewController: UIViewController, PaymentConfirmationViewControlling {

    var presenter: PaymentPresenting?

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let infoBanner = InfoBanner(message: "Pastikan nama penjual dan jumlah yang dibayar telah sesuai.")
    private let receiverHeader = SectionHeaderLabel(text: "Penerima")
    private let receiverCard = CardView()
    private let receiverNameLabel = UILabel()
    private let receiverLocationLabel = UILabel()

    private let sourceHeader = SectionHeaderLabel(text: "Sumber dana")
    private let sourceCard = CardView()
    private let sourceTitleLabel = UILabel()
    private let sourceDetailLabel = UILabel()

    private let detailsHeader = SectionHeaderLabel(text: "Detail pembayaran")
    private let detailsSeparator = UIView()
    private let nominalLabel = UILabel()
    private let nominalAmountLabel = UILabel()

    private let bottomContainer = UIView()
    private let totalCaptionLabel = UILabel()
    private let totalAmountLabel = UILabel()
    private let payButton = PrimaryButton(title: "Bayar Sekarang")
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.Color.surface
        title = "Konfirmasi"
        navigationItem.backButtonDisplayMode = .minimal
        setupViews()
        presenter?.viewDidLoad()
    }

    private func setupViews() {
        receiverNameLabel.font = DesignSystem.Typography.bodyBold()
        receiverNameLabel.textColor = DesignSystem.Color.textPrimary
        receiverNameLabel.adjustsFontForContentSizeCategory = true

        receiverLocationLabel.font = DesignSystem.Typography.body()
        receiverLocationLabel.textColor = DesignSystem.Color.textSecondary
        receiverLocationLabel.adjustsFontForContentSizeCategory = true

        sourceTitleLabel.font = DesignSystem.Typography.body()
        sourceTitleLabel.textColor = DesignSystem.Color.textPrimary
        sourceTitleLabel.adjustsFontForContentSizeCategory = true

        sourceDetailLabel.font = DesignSystem.Typography.body()
        sourceDetailLabel.textColor = DesignSystem.Color.textSecondary
        sourceDetailLabel.adjustsFontForContentSizeCategory = true

        detailsSeparator.backgroundColor = DesignSystem.Color.cardBorder

        nominalLabel.text = "Nominal"
        nominalLabel.font = DesignSystem.Typography.body()
        nominalLabel.textColor = DesignSystem.Color.textSecondary
        nominalLabel.adjustsFontForContentSizeCategory = true

        nominalAmountLabel.font = DesignSystem.Typography.body()
        nominalAmountLabel.textColor = DesignSystem.Color.textPrimary
        nominalAmountLabel.textAlignment = .right
        nominalAmountLabel.adjustsFontForContentSizeCategory = true

        bottomContainer.backgroundColor = DesignSystem.Color.surface
        bottomContainer.layer.shadowColor = UIColor.black.cgColor
        bottomContainer.layer.shadowOpacity = 0.05
        bottomContainer.layer.shadowRadius = 8
        bottomContainer.layer.shadowOffset = CGSize(width: 0, height: -2)

        totalCaptionLabel.text = "Total"
        totalCaptionLabel.font = DesignSystem.Typography.body()
        totalCaptionLabel.textColor = DesignSystem.Color.textSecondary
        totalCaptionLabel.adjustsFontForContentSizeCategory = true

        totalAmountLabel.font = DesignSystem.Typography.bodyBold()
        totalAmountLabel.textColor = DesignSystem.Color.textPrimary
        totalAmountLabel.textAlignment = .right
        totalAmountLabel.adjustsFontForContentSizeCategory = true

        payButton.addTarget(self, action: #selector(didTapPay), for: .touchUpInside)
        payButton.accessibilityIdentifier = "payment.payButton"
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .black

        view.addSubview(scrollView)
        view.addSubview(bottomContainer)
        scrollView.addSubview(contentView)

        contentView.addSubview(infoBanner)
        contentView.addSubview(receiverHeader)
        contentView.addSubview(receiverCard)
        receiverCard.addSubview(receiverNameLabel)
        receiverCard.addSubview(receiverLocationLabel)
        contentView.addSubview(sourceHeader)
        contentView.addSubview(sourceCard)
        sourceCard.addSubview(sourceTitleLabel)
        sourceCard.addSubview(sourceDetailLabel)
        contentView.addSubview(detailsHeader)
        contentView.addSubview(detailsSeparator)
        contentView.addSubview(nominalLabel)
        contentView.addSubview(nominalAmountLabel)

        bottomContainer.addSubview(totalCaptionLabel)
        bottomContainer.addSubview(totalAmountLabel)
        bottomContainer.addSubview(payButton)
        bottomContainer.addSubview(activityIndicator)

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(bottomContainer.snp.top)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        infoBanner.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        receiverHeader.snp.makeConstraints { make in
            make.top.equalTo(infoBanner.snp.bottom).offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        receiverCard.snp.makeConstraints { make in
            make.top.equalTo(receiverHeader.snp.bottom).offset(DesignSystem.Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        receiverNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        receiverLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(receiverNameLabel.snp.bottom).offset(DesignSystem.Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        sourceHeader.snp.makeConstraints { make in
            make.top.equalTo(receiverCard.snp.bottom).offset(DesignSystem.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        sourceCard.snp.makeConstraints { make in
            make.top.equalTo(sourceHeader.snp.bottom).offset(DesignSystem.Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        sourceTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        sourceDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(sourceTitleLabel.snp.bottom).offset(DesignSystem.Spacing.xxs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        detailsHeader.snp.makeConstraints { make in
            make.top.equalTo(sourceCard.snp.bottom).offset(DesignSystem.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        detailsSeparator.snp.makeConstraints { make in
            make.top.equalTo(detailsHeader.snp.bottom).offset(DesignSystem.Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.height.equalTo(1)
        }
        nominalLabel.snp.makeConstraints { make in
            make.top.equalTo(detailsSeparator.snp.bottom).offset(DesignSystem.Spacing.md)
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.lg)
        }
        nominalAmountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nominalLabel)
            make.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.xl)
        }

        bottomContainer.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        totalCaptionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.lg)
        }
        totalAmountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(totalCaptionLabel)
            make.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        payButton.snp.makeConstraints { make in
            make.top.equalTo(totalCaptionLabel.snp.bottom).offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.bottom.equalTo(bottomContainer.safeAreaLayoutGuide.snp.bottom).inset(DesignSystem.Spacing.sm)
            make.height.equalTo(56)
        }
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(payButton)
        }
    }

    @objc private func didTapPay() {
        presenter?.didTapPay()
    }

    func render(_ viewModel: PaymentConfirmationViewModel) {
        receiverNameLabel.text = viewModel.merchantName
        receiverLocationLabel.text = viewModel.merchantLocation
        sourceTitleLabel.text = viewModel.sourceAccountHolder
        sourceDetailLabel.text = "\(viewModel.sourceAccountType) · \(viewModel.sourceAccountNumber)"
        nominalAmountLabel.text = viewModel.formattedAmount
        totalAmountLabel.text = viewModel.formattedAmount

        receiverNameLabel.accessibilityLabel = "Penerima \(viewModel.merchantName), \(viewModel.merchantLocation)"
        nominalAmountLabel.accessibilityLabel = "Nominal \(viewModel.formattedAmount)"
        totalAmountLabel.accessibilityLabel = "Total \(viewModel.formattedAmount)"
    }

    func setLoading(_ loading: Bool) {
        payButton.setEnabledState(!loading)
        if loading {
            payButton.configuration?.title = ""
            activityIndicator.startAnimating()
        } else {
            payButton.configuration?.title = "Bayar Sekarang"
            var attr = AttributeContainer()
            attr.font = DesignSystem.Typography.button()
            payButton.configuration?.attributedTitle = AttributedString("Bayar Sekarang", attributes: attr)
            activityIndicator.stopAnimating()
        }
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Pembayaran Gagal", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

final class SectionHeaderLabel: UILabel {
    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        self.font = DesignSystem.Typography.bodyBold()
        self.textColor = DesignSystem.Color.textPrimary
        self.adjustsFontForContentSizeCategory = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#if DEBUG
private final class PreviewPaymentInteractor: PaymentInteracting {
    var balance = 1_999_999
    var paymentResult: Result<PaymentReceipt, any Error> = .success(PaymentReceipt(referenceId: "981273465928734", approvedAt: Date()))
    
    func currentBalance() -> Int { balance }
    
    func executePayment(_ transaction: QRISTransaction) async -> Result<PaymentReceipt, any Error> { paymentResult }
}

private final class PreviewPaymentRouter: PaymentRouting {
    func presentSuccess(transaction: QRISTransaction, receipt: PaymentReceipt, from view: UIViewController) {}
    func returnToHome(from view: UIViewController) {}
}

private final class PreviewUserRepository: UserRepository {
    let user = UserProfile(fullName: "Confirmation Account", accountType: "Tester Confirmation", accountNumber: "2238842561")
    func currentUser() -> UserProfile { user }
}

#Preview("Default") {
    let view = PaymentConfirmationViewController()
    let interactor = PreviewPaymentInteractor()
    let router = PreviewPaymentRouter()
    let userRepository = PreviewUserRepository()
    let presenter = PaymentPresenter(view: view, interactor: interactor, router: router, transaction: QRISTransaction(bank: "CONFIRM", transactionId: "812374659823569", merchantName: "Confirmation Merchant", amount: 1_999_888), userRepository: PreviewUserRepository())
    view.presenter = presenter
    return UINavigationController(rootViewController: view)
}

#endif
