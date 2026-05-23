import Foundation

/// Indonesian Rupiah formatting matching the reference UI: "Rp150.000" (no space,
/// dot thousands separator). Wraps NumberFormatter so we don't allocate on every call.
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
