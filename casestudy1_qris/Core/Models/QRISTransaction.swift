import Foundation

/// Decoded contents of a QRIS code in the format `BANK.TXID.MERCHANT.AMOUNT`.
struct QRISTransaction: Equatable, Hashable {
    let bank: String
    let transactionId: String
    let merchantName: String
    let amount: Int
}

/// A completed payment, persisted to the transaction history.
struct PaymentRecord: Codable, Equatable, Hashable, Identifiable {
    let id: String
    let bank: String
    let transactionId: String
    let merchantName: String
    let amount: Int
    let referenceId: String
    let timestamp: Date

    init(
        id: String = UUID().uuidString,
        bank: String,
        transactionId: String,
        merchantName: String,
        amount: Int,
        referenceId: String,
        timestamp: Date
    ) {
        self.id = id
        self.bank = bank
        self.transactionId = transactionId
        self.merchantName = merchantName
        self.amount = amount
        self.referenceId = referenceId
        self.timestamp = timestamp
    }
}

struct UserProfile: Codable, Equatable {
    let fullName: String
    let accountType: String
    let accountNumber: String
    
    var firstName: String {
        fullName.split(separator: " ").first.map(String.init) ?? fullName
    }
    
    // masked from model because all masked acc number is the same, single source of truth
    var maskedAccountNumber: String {
        let suffix = accountNumber.suffix(3)
        let stars = String(repeating: "*", count: max(0, accountNumber.count - 3))
        return stars + suffix
    }
}
