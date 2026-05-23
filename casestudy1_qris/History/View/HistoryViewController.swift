import UIKit
import SnapKit

final class HistoryViewController: UIViewController, HistoryViewControlling, UITableViewDataSource, UITableViewDelegate {

    var presenter: HistoryPresenting?

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let emptyView = HistoryEmptyView()
    private var sections: [HistorySection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = DesignSystem.Color.surface
        title = "Riwayat"
        navigationController?.navigationBar.prefersLargeTitles = false
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.viewWillAppear()
    }

    private func setupViews() {
        tableView.backgroundColor = DesignSystem.Color.surface
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseId)
        tableView.estimatedRowHeight = 72
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionHeaderTopPadding = 0

        view.addSubview(tableView)
        view.addSubview(emptyView)
        tableView.snp.makeConstraints { make in make.edges.equalToSuperview() }
        emptyView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.xl)
        }
        emptyView.isHidden = true
    }

    func render(rows: [HistoryRowViewModel]) {
        sections = HistorySection.group(rows: rows)
        emptyView.isHidden = !rows.isEmpty
        tableView.isHidden = rows.isEmpty
        tableView.reloadData()
    }

    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.reuseId, for: indexPath) as! HistoryCell
        cell.configure(with: sections[indexPath.section].rows[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].header
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let container = UIView()
        container.backgroundColor = DesignSystem.Color.surface
        let label = UILabel()
        label.text = sections[section].header
        label.font = DesignSystem.Typography.sectionHeader()
        label.textColor = DesignSystem.Color.textSecondary
        label.adjustsFontForContentSizeCategory = true
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
            make.top.bottom.equalToSuperview().inset(DesignSystem.Spacing.xs)
        }
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 36 }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = sections[indexPath.section].rows[indexPath.row]
        presenter?.didSelectRow(id: row.id)
    }
}

private struct HistorySection {
    let header: String
    let rows: [HistoryRowViewModel]

    static func group(rows: [HistoryRowViewModel]) -> [HistorySection] {
        var result: [HistorySection] = []
        var current: (header: String, items: [HistoryRowViewModel])?
        for row in rows {
            if current?.header == row.dayHeader {
                current?.items.append(row)
            } else {
                if let c = current { result.append(HistorySection(header: c.header, rows: c.items)) }
                current = (row.dayHeader, [row])
            }
        }
        if let c = current { result.append(HistorySection(header: c.header, rows: c.items)) }
        return result
    }
}

private final class HistoryCell: UITableViewCell {

    static let reuseId = "HistoryCell"

    private let container = CardView()
    private let icon = UIImageView()
    private let iconBackground = UIView()
    private let merchantLabel = UILabel()
    private let timeLabel = UILabel()
    private let amountLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .default
        let selectedBg = UIView()
        selectedBg.backgroundColor = DesignSystem.Color.primary.withAlphaComponent(0.08)
        selectedBackgroundView = selectedBg
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        iconBackground.backgroundColor = DesignSystem.Color.primary.withAlphaComponent(0.18)
        iconBackground.layer.cornerRadius = 20

        icon.image = UIImage(systemName: "qrcode", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
        icon.tintColor = DesignSystem.Color.primaryText
        icon.contentMode = .scaleAspectFit

        merchantLabel.font = DesignSystem.Typography.bodyBold()
        merchantLabel.textColor = DesignSystem.Color.textPrimary
        merchantLabel.adjustsFontForContentSizeCategory = true

        timeLabel.font = DesignSystem.Typography.caption()
        timeLabel.textColor = DesignSystem.Color.textSecondary
        timeLabel.adjustsFontForContentSizeCategory = true

        amountLabel.font = DesignSystem.Typography.bodyBold()
        amountLabel.textColor = DesignSystem.Color.textPrimary
        amountLabel.textAlignment = .right
        amountLabel.adjustsFontForContentSizeCategory = true

        contentView.addSubview(container)
        container.addSubview(iconBackground)
        iconBackground.addSubview(icon)
        container.addSubview(merchantLabel)
        container.addSubview(timeLabel)
        container.addSubview(amountLabel)

        container.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.leading.trailing.equalToSuperview().inset(DesignSystem.Spacing.lg)
        }
        iconBackground.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        icon.snp.makeConstraints { make in make.center.equalToSuperview() }
        merchantLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(DesignSystem.Spacing.md)
            make.leading.equalTo(iconBackground.snp.trailing).offset(DesignSystem.Spacing.sm)
            make.trailing.lessThanOrEqualTo(amountLabel.snp.leading).offset(-DesignSystem.Spacing.xs)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(merchantLabel.snp.bottom).offset(2)
            make.leading.equalTo(merchantLabel)
            make.bottom.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
        amountLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(DesignSystem.Spacing.md)
        }
    }

    func configure(with row: HistoryRowViewModel) {
        merchantLabel.text = row.merchantName
        timeLabel.text = row.formattedTimestamp
        amountLabel.text = row.formattedAmount
        accessibilityLabel = "\(row.merchantName), \(row.formattedAmount), \(row.formattedTimestamp)"
        isAccessibilityElement = true
    }
}

private final class HistoryEmptyView: UIView {
    private let imageView = UIImageView(image: UIImage(systemName: "tray"))
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()

    init() {
        super.init(frame: .zero)
        imageView.tintColor = DesignSystem.Color.textTertiary
        imageView.contentMode = .scaleAspectFit

        titleLabel.text = "Belum ada transaksi"
        titleLabel.font = DesignSystem.Typography.bodyBold()
        titleLabel.textColor = DesignSystem.Color.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontForContentSizeCategory = true

        bodyLabel.text = "Riwayat pembayaran QRIS Anda akan muncul di sini."
        bodyLabel.font = DesignSystem.Typography.body()
        bodyLabel.textColor = DesignSystem.Color.textSecondary
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.adjustsFontForContentSizeCategory = true

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = DesignSystem.Spacing.sm
        addSubview(stack)
        stack.snp.makeConstraints { make in make.edges.equalToSuperview() }
        imageView.snp.makeConstraints { make in make.height.width.equalTo(48) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
