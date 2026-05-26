import Foundation

enum BalanceError: Error, Equatable {
    case insufficientFunds
}

protocol BalanceRepository {
    func currentBalance() -> Int
    @discardableResult
    func deduct(_ amount: Int) throws -> Int
    func reset(to amount: Int)
}

final class DefaultBalanceRepository: BalanceRepository {

    private let store: KeychainStore
    private let key = "balance"
    private let queue = DispatchQueue(label: "qris.balance", qos: .userInitiated)
    private var cached: Int

    init(store: KeychainStore, seedBalance: Int) {
        self.store = store
        if let existing = store.int(for: key) {
            self.cached = existing
        } else {
            store.setInt(seedBalance, for: key)
            self.cached = seedBalance
        }
    }

    func currentBalance() -> Int {
        queue.sync { cached }
    }

    @discardableResult
    func deduct(_ amount: Int) throws -> Int {
        try queue.sync {
            guard cached >= amount else {
                throw BalanceError.insufficientFunds
            }
            cached -= amount
            store.setInt(cached, for: key)
            return cached
        }
    }

    func reset(to amount: Int) {
        queue.sync {
            cached = amount
            store.setInt(amount, for: key)
        }
    }
}
