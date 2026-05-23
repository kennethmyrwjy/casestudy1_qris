import Foundation

protocol PaymentInteracting: AnyObject {
    func currentBalance() -> Int
    func executePayment(_ transaction: QRISTransaction) async -> Result<PaymentReceipt, Error>
}

final class PaymentInteractor: PaymentInteracting {

    private let balanceRepository: BalanceRepository
    private let executionService: PaymentExecutionService
//    private let transactionRepository: TransactionRepository now in executionservice

    init(
        balanceRepository: BalanceRepository,
        executionService: PaymentExecutionService
    ) {
        self.balanceRepository = balanceRepository
        self.executionService = executionService
    }

    func currentBalance() -> Int {
        balanceRepository.currentBalance()
    }

    func executePayment(_ transaction: QRISTransaction) async -> Result<PaymentReceipt, Error> {
        await executionService.execute(transaction)
    }
}
