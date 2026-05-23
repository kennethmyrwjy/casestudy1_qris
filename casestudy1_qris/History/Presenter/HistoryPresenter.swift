import UIKit

protocol HistoryPresenting: AnyObject {
    func viewWillAppear()
    func didSelectRow(id: String)
}

protocol HistoryViewControlling: AnyObject {
    func render(rows: [HistoryRowViewModel])
}

final class HistoryPresenter: HistoryPresenting {

    private weak var view: HistoryViewControlling?
    private let interactor: HistoryInteracting
    private let router: HistoryRouting

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "HH:mm"
        return f
    }()

    init(view: HistoryViewControlling, interactor: HistoryInteracting, router: HistoryRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewWillAppear() {
        let records = interactor.loadHistory()
        let rows = records.map { record in
            HistoryRowViewModel(
                id: record.id,
                merchantName: record.merchantName.capitalizedDisplay,
                formattedAmount: "-" + CurrencyFormatter.format(record.amount),
                formattedTimestamp: timeFormatter.string(from: record.timestamp) + " WIB",
                dayHeader: ReceiptDateFormatter.listString(from: record.timestamp)
            )
        }
        view?.render(rows: rows)
    }

    func didSelectRow(id: String) {
        guard
            let record = interactor.record(withId: id),
            let viewController = view as? UIViewController
        else { return }
        router.presentTransactionDetail(record, from: viewController)
    }
}

private extension String {
    var capitalizedDisplay: String {
        let lower = lowercased()
        return lower.split(separator: " ").map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined(separator: " ")
    }
}
