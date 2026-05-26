import Foundation

protocol TransactionRepository {
    func all() -> [PaymentRecord]
    func add(_ record: PaymentRecord)
    func clear()
}

final class DefaultTransactionRepository: TransactionRepository {

    private let defaults: UserDefaults
    private let key: String
    private let queue = DispatchQueue(label: "qris.history", qos: .userInitiated)
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults, key: String) {
        self.defaults = defaults
        self.key = key
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    func all() -> [PaymentRecord] {
        queue.sync {
            guard let data = defaults.data(forKey: key) else { return [] }
            return (try? decoder.decode([PaymentRecord].self, from: data)) ?? []
        }
    }

    func add(_ record: PaymentRecord) {
        queue.sync {
            var current = loadLocked()
            current.insert(record, at: 0)
            saveLocked(current)
        }
    }

    func clear() {
        queue.sync {
            defaults.removeObject(forKey: key)
        }
    }

    private func loadLocked() -> [PaymentRecord] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? decoder.decode([PaymentRecord].self, from: data)) ?? []
    }

    private func saveLocked(_ records: [PaymentRecord]) {
        guard let data = try? encoder.encode(records) else { return }
        defaults.set(data, forKey: key)
    }
}
