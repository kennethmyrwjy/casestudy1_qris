import Foundation

struct HomeViewModel: Equatable {
    let formattedBalance: String
    let greeting: String
    let isSensitiveDataHidden: Bool
//    let fullName: String // dropped, not used for now
    let accountType: String
//    let accountNumber: String
    
    let formattedAccountNumber: String
}
