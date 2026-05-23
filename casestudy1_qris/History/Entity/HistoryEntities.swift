import Foundation

struct HistoryRowViewModel: Equatable, Hashable {
    let id: String
    let merchantName: String
    let formattedAmount: String
    let formattedTimestamp: String
    let dayHeader: String
}
