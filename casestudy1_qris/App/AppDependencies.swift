import Foundation

final class AppDependencies {

    static let shared = AppDependencies()

    private(set) var balanceRepository: BalanceRepository!
    private(set) var transactionRepository: TransactionRepository!
    private(set) var paymentGateway: PaymentGateway!
    private(set) var paymentExecutionService: PaymentExecutionService!
    private(set) var qrParser: QRParser!
    private(set) var userRepository: UserRepository!

    private init() {} // to avoid force unwrap init here

    func bootstrap() {
        // separate namespace to avoid colliding/overlap, same pattern apple uses
        
        let balanceKeychain = KeychainStore(service: "com.example.casestudy1-qris.balance")
        balanceRepository = DefaultBalanceRepository(
            store: balanceKeychain,
            seedBalance: 1_500_000
        )
        transactionRepository = DefaultTransactionRepository(
            defaults: .standard,
            key: "tx.history.v1"
        )
        
        let userKeychain = KeychainStore(service: "com.example.casestudy1-qris.user")
        userRepository = DefaultUserRepository(defaults: .standard, keychain: userKeychain, seed: UserProfile(
            fullName: "Kenneth Mayer Wijaya",
            accountType: "Taplus Muda",
            accountNumber: "0674646111"
        ))
        paymentGateway = AlamofirePaymentGateway()
        // af for quick code & less boilerplate, urlession for more security
        paymentExecutionService = DefaultPaymentExecutionService(balanceRepository: balanceRepository, transactionRepository: transactionRepository, gateway: paymentGateway)
        qrParser = DefaultQRParser()
    }
}
