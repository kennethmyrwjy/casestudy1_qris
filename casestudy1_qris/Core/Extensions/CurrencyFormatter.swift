import Foundation

enum CurrencyFormatter {

    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.numberStyle = .currency
        f.currencySymbol = "Rp"
        f.maximumFractionDigits = 0
        f.minimumFractionDigits = 0
        f.usesGroupingSeparator = true
        f.groupingSeparator = "."
        return f
    }()

    static func format(_ amount: Int) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "Rp\(amount)"
    }
}
