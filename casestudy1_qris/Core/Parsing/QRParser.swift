import Foundation

enum QRParseError: Error, Equatable {
    case empty
    case wrongFieldCount(expected: Int, actual: Int)
    case unknownBank(String)
    case invalidTransactionId
    case invalidMerchantName
    case invalidAmount
    case nonPositiveAmount
}

enum SupportedBank: String, CaseIterable {
    case bni = "BNI"
    case bca = "BCA"
    case bri = "BRI"
    case mandiri = "MANDIRI"
    case btn = "BTN"
}

protocol QRParser {
    func parse(_ raw: String) -> Result<QRISTransaction, QRParseError>
}

struct DefaultQRParser: QRParser {

    func parse(_ raw: String) -> Result<QRISTransaction, QRParseError> {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.empty) }

        let parts = trimmed.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard parts.count == 4 else {
            return .failure(.wrongFieldCount(expected: 4, actual: parts.count))
        }

        let bank = parts[0]
        let transactionId = parts[1]
        let merchantName = parts[2]
        let amountString = parts[3]

        guard SupportedBank(rawValue: bank.uppercased()) != nil else {
            return .failure(.unknownBank(bank))
        }
        guard !transactionId.isEmpty else { return .failure(.invalidTransactionId) }
        guard !merchantName.isEmpty else { return .failure(.invalidMerchantName) }
        guard let amount = Int(amountString) else { return .failure(.invalidAmount) }
        guard amount > 0 else { return .failure(.nonPositiveAmount) }

        return .success(
            QRISTransaction(
                bank: bank.uppercased(),
                transactionId: transactionId,
                merchantName: merchantName,
                amount: amount
            )
        )
    }
}
