import Foundation

protocol HomeInteracting: AnyObject {
    func fetchBalance() -> Int
    func recentTransactionCount() -> Int
    func currentUser() -> UserProfile
}

final class HomeInteractor: HomeInteracting {

    private let balanceRepository: BalanceRepository
    private let transactionRepository: TransactionRepository
    private let userRepository: UserRepository

    init(balanceRepository: BalanceRepository, transactionRepository: TransactionRepository, userRepository: UserRepository) {
        self.balanceRepository = balanceRepository
        self.transactionRepository = transactionRepository
        self.userRepository = userRepository
    }

    func fetchBalance() -> Int {
        balanceRepository.currentBalance()
    }

    func recentTransactionCount() -> Int {
        transactionRepository.all().count
    }
    
    func currentUser() -> UserProfile { userRepository.currentUser() }
}
