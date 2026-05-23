import Foundation

protocol HistoryInteracting: AnyObject {
    func loadHistory() -> [PaymentRecord]
    func record(withId id: String) -> PaymentRecord?
}

final class HistoryInteractor: HistoryInteracting {

    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    func loadHistory() -> [PaymentRecord] {
        repository.all().sorted { $0.timestamp > $1.timestamp }
    }

    func record(withId id: String) -> PaymentRecord? {
        repository.all().first(where: { $0.id == id })
    }
}
