import UIKit
import SnapKit

enum PaymentSuccessMode {
    /// Fresh payment — big celebratory framing, success haptic, return-to-home CTA.
    case freshPayment
    /// Viewing a past transaction from Riwayat — no haptic, standard back button,
    /// no "berhasil" celebration in the title.
    case historyDetail
}

struct PaymentSuccessContext {
    let mode: PaymentSuccessMode
    let merchantName: String
    let amount: Int
    let approvedAt: Date
    let referenceId: String
    let sourceAccountHolder: String
    let sourceAccountTypeWithMaskedNumber: String // ex: Taplus Muda : xxxxxx00

    init(from transaction: QRISTransaction, receipt: PaymentReceipt, userProfile: UserProfile) {
        self.mode = .freshPayment
        self.merchantName = transaction.merchantName
        self.amount = transaction.amount
        self.approvedAt = receipt.approvedAt
        self.referenceId = receipt.referenceId
        self.sourceAccountHolder = userProfile.fullName
        self.sourceAccountTypeWithMaskedNumber = "\(userProfile.accountType) · \(Self.mask(userProfile.accountNumber))"
    }

    init(from record: PaymentRecord, userProfile: UserProfile) {
        self.mode = .historyDetail
        self.merchantName = record.merchantName
        self.amount = record.amount
        self.approvedAt = record.timestamp
        self.referenceId = record.referenceId
        self.sourceAccountHolder = userProfile.fullName
        self.sourceAccountTypeWithMaskedNumber = "\(userProfile.accountType) · \(Self.mask(userProfile.accountNumber))"
    }
    
    private static func mask(_ accountNumber: String) -> String {
        let suffix = accountNumber.suffix(3)
        let stars = String(repeating: "*", count: max(0, accountNumber.count - 3))
        return stars + suffix
    }
}

final class PaymentSuccessViewController: UIViewController {

    private let context: PaymentSuccessContext
    private let onReturnHome: () -> Void

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let illustrationView = UIView()
    private let checkmarkBadge = UIView()
    private let illustrationIcon = UIImageView()
    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let metaLabel = UILabel()
    private let actionsStack = UIStackView()
    private let receiptHeader = SectionHeaderLabel(text: "Penerima")
    private let receiverCard = CardView()
    private let receiverNameLabel = UILabel()
    private let receiverLocationLabel = UILabel()
    private let sourceHeader = SectionHeaderLabel(text: "Sumber dana")
    private let sourceCard = CardView()
    private let sourceTitleLabel = UILabel()
    private let sourceDetailLabel = UILabel()
    private let bottomContainer = UIView()
    private let returnButton = PrimaryButton(title: "Kembali ke Beranda")

    init(context: PaymentSuccessContext, onReturnHome: @escaping () -> Void) {
        self.context = context
        self.onReturnHome = onReturnHome
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.Color.surface
        switch context.mode {
        case .freshPayment:
            navigationItem.setHidesBackButton(true, animated: false)
            title = nil
        case .historyDetail:
            title = "Detail Transaksi"
            navigationItem.backButtonDisplayMode = .minimal
        }
        setupViews()
        populate()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Fired here rather than viewDidLoad so the haptic syncs with the screen
        // becoming visible after the push animation. Only fires for fresh payments
        // — re-opening a past transaction from Riwayat shouldn't celebrate.
        if context.mode == .freshPayment {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func setupViews() {
        illustrationView.backgroundColor = DesignSystem.Color.secondaryOpaque
        illustrationView.layer.cornerRadius = DesignSystem.Radius.card

        illustrationIcon.image = UIImage(
            systemName: "qrcode",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 56, weight: .regular)
        )
        illustrationIcon.tintColor = DesignSystem.Color.secondary
        illustrationIcon.contentMode = .scaleAspectFit

        checkmarkBadge.backgroundColor = DesignSystem.Color.secondary
        checkmarkBadge.layer.cornerRadius = 18
        let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)))
        check.tintColor = .white
        check.contentMode = .scaleAspectFit
        checkmarkBadge.addSubview(check)
        check.snp.makeConstraints { make in make.center.equalToSuperview() }

        titleLabel.text = context.mode == .freshPayment
            ? "Pembayaran QRIS berhasil"
            : "Pembayaran QRIS"
        titleLabel.font = DesignSystem.Typography.successTitle()
        titleLabel.textColor = DesignSystem.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true

        amountLabel.font = DesignSystem.Typography.amountLarge()
        amountLabel.textColor = DesignSystem.Color.textPrimary
        amountLabel.textAlignment = .center
        amountLabel.adjustsFontForContentSizeCategory = true

        metaLabel.font = DesignSystem.Typography.caption()
        metaLabel.textColor = DesignSystem.Color.textSecondary
        metaLabel.textAlignment = .center
        metaLabel.numberOfLines = 2
        metaLabel.adjustsFontForContentSizeCategory = true

        actionsStack.axis = .horizontal
        actionsStack.distribution = .equalSpacing
        actionsStack.spacing = DesignSystem.Spacing.xl
        actionsStack.alignment = .center
        let receiptAction = SuccessActionButton(title: "Bukti\nTransaksi", systemImage: "doc.text")
        let shareAction = SuccessActionButton(title: "Bagikan", systemImage: "square.and.arrow.up")
        receiptAction.addTarget(self, action: #selector(noop), for: .touchUpInside)
        shareAction.addTarget(self, action: #selector(didTapShare), for: .touchUpInside)
        actionsStack.addArrangedSubview(receiptAction)
        actionsStack.addArrangedSubview(shareAction)

        receiverNameLabel.font = DesignSystem.Typography.body()
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

        returnButton.addTarget(self, action: #selector(didTapReturn), for: .touchUpInside)

        view.addSubview(scrollView)
        if context.mode == .freshPayment {
            view.addSubview(bottomContainer)
        }
        scrollView.addSubview(contentView)
        contentView.addSubview(illustrationView)
        illustrationView.addSubview(illustrationIcon)
        contentView.addSubview(checkmarkBadge)
        contentView.addSubview(titleLabel)
        contentView.addSubview(amountLabel)
        contentView.addSubview(metaLabel)
        contentView.addSubview(receiptHeader)
        contentView.addSubview(receiverCard)
        receiverCard.addSubview(receiverNameLabel)
        receiverCard.addSubview(receiverLocationLabel)
        contentView.addSubview(sourceHeader)
        contentView.addSubview(sourceCard)
        sourceCard.addSubview(sourceTitleLabel)
        sourceCard.addSubview(sourceDetailLabel)
        if context.mode == .freshPayment {
            bottomContainer.addSubview(returnButton)
        }

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            if context.mode == .freshPayment {
                make.bottom.equalTo(bottomContainer.snp.top)
            } else {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        illustrationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.lg)
            make.centerX.equalToSuperview()
            make.width.equalTo(170)
            make.height.equalTo(110)
        }
        illustrationIcon.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        checkmarkBadge.snp.makeConstraints { make in
            make.trailing.equalTo(illustrationView.snp.trailing).offset(8)
            make.bottom.equalTo(illustrationView.snp.bottom).offset(8)
            make.width.height.equalTo(36)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(illustrationView.snp.bottom).offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        amountLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(DesignSystem.Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        metaLabel.snp.makeConstraints { make in
            make.top.equalTo(amountLabel.snp.bottom).offset(DesignSystem.Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        receiptHeader.snp.makeConstraints { make in
            make.top.equalTo(metaLabel.snp.bottom).offset(DesignSystem.Spacing.lg)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        receiverCard.snp.makeConstraints { make in
            make.top.equalTo(receiptHeader.snp.bottom).offset(DesignSystem.Spacing.xs)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        receiverNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        receiverLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(receiverNameLabel.snp.bottom).offset(DesignSystem.Spacing.xxs)
            make.leading.trailing.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        sourceHeader.snp.makeConstraints { make in
            make.top.equalTo(receiverCard.snp.bottom).offset(DesignSystem.Spacing.md)
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
            make.leading.trailing.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        contentView.snp.makeConstraints { make in
            make.bottom.equalTo(sourceCard.snp.bottom).offset(DesignSystem.Spacing.lg)
        }
        if context.mode == .freshPayment {
            bottomContainer.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalToSuperview()
            }
            returnButton.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(DesignSystem.Spacing.sm)
                make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
                make.bottom.equalTo(bottomContainer.safeAreaLayoutGuide.snp.bottom).inset(DesignSystem.Spacing.sm)
                make.height.equalTo(56)
            }
        }
    }

    private func populate() {
        let formattedAmount = CurrencyFormatter.format(context.amount)
        amountLabel.text = formattedAmount
        // Force a two-line layout (date+time on top, Ref ID below) to mirror the reference.
        metaLabel.text = "\(ReceiptDateFormatter.receiptString(from: context.approvedAt)) ·\nRef ID: \(context.referenceId)"
        receiverNameLabel.text = context.merchantName.capitalizedDisplay
        receiverLocationLabel.text = "Jakarta, Indonesia"
        sourceTitleLabel.text = context.sourceAccountHolder
        sourceDetailLabel.text = context.sourceAccountTypeWithMaskedNumber

        amountLabel.accessibilityLabel = "Jumlah pembayaran \(formattedAmount)"
        titleLabel.accessibilityTraits.insert(.header)
    }

    @objc private func didTapReturn() { onReturnHome() }
    @objc private func noop() {}
    @objc private func didTapShare() {
        let text = "Pembayaran QRIS ke \(context.merchantName) sebesar \(CurrencyFormatter.format(context.amount)) berhasil. Ref: \(context.referenceId)"
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activity, animated: true)
    }
}

private final class SuccessActionButton: UIControl {
    private let circle = UIView()
    private let iconView = UIImageView()
    private let label = UILabel()

    init(title: String, systemImage: String) {
        super.init(frame: .zero)
        configure(title: title, systemImage: systemImage)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure(title: String, systemImage: String) {
        circle.backgroundColor = DesignSystem.Color.secondary
        circle.layer.cornerRadius = 14
        iconView.image = UIImage(systemName: systemImage, withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        label.text = title
        label.font = DesignSystem.Typography.caption()
        label.textColor = DesignSystem.Color.textSecondary
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true

        addSubview(circle)
        circle.addSubview(iconView)
        addSubview(label)
        circle.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.height.equalTo(56)
        }
        iconView.snp.makeConstraints { make in make.center.equalToSuperview() }
        label.snp.makeConstraints { make in
            make.top.equalTo(circle.snp.bottom).offset(6)
            make.leading.trailing.bottom.equalToSuperview()
        }
        snp.makeConstraints { make in make.width.equalTo(80) }
        isAccessibilityElement = true
        accessibilityLabel = title.replacingOccurrences(of: "\n", with: " ")
        accessibilityTraits = .button
    }
}

private extension String {
    var capitalizedDisplay: String {
        let lower = lowercased()
        return lower.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }
}

#if DEBUG

#Preview("New Payment") {
    let paymentSuccessContext = PaymentSuccessContext(
        from: QRISTransaction(bank: "NEW", transactionId: "NEW987654321", merchantName: "New Merchant", amount: 9999999), receipt: PaymentReceipt(referenceId: "265985692983472", approvedAt: Date()), userProfile: UserProfile(fullName: "New Account Owner", accountType: "Tester New", accountNumber: "1234567890")
    )
    let vc = PaymentSuccessViewController(context: paymentSuccessContext, onReturnHome: { })
    return UINavigationController(rootViewController: vc)
}

#Preview("History Payment") {
    let paymentSuccessContext = PaymentSuccessContext(from: PaymentRecord(bank: "HISTORY", transactionId: "HIST123456789", merchantName: "History Preview Merchant", amount: 8888888, referenceId: "019283475687324", timestamp: Date()), userProfile: UserProfile(fullName: "History Account Owner", accountType: "Tester History", accountNumber: "3487532909"))
    let vc = PaymentSuccessViewController(context: paymentSuccessContext, onReturnHome: {})
    return UINavigationController(rootViewController: vc)
}

#endif
