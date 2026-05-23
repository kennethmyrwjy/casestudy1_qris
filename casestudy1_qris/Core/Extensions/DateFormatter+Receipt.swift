import Foundation

enum ReceiptDateFormatter {

    private static let display: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "d MMM yyyy · HH:mm:ss"
        return f
    }()

    private static let listDay: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "id_ID")
        f.dateFormat = "d MMM yyyy"
        return f
    }()

    static func receiptString(from date: Date) -> String {
        "\(display.string(from: date)) WIB"
    }

    static func listString(from date: Date) -> String {
        listDay.string(from: date)
    }
}
