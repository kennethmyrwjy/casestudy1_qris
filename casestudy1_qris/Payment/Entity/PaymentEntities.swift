import Foundation

struct PaymentConfirmationViewModel: Equatable {
    let merchantName: String
    let merchantLocation: String
    let sourceAccountHolder: String
    let sourceAccountType: String
    let sourceAccountNumber: String
    let amount: Int
    let formattedAmount: String
}

struct PaymentSuccessViewModel: Equatable {
    let formattedAmount: String
    let timestamp: String
    let referenceId: String
    let merchantName: String
    let merchantLocation: String
    let sourceAccountHolder: String
    let sourceAccountMasked: String
}
