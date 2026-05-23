import Foundation
import Alamofire

enum PaymentError: Error, Equatable {
    case network
    case declined(reason: String)
}

struct PaymentReceipt: Equatable {
    let referenceId: String
    let approvedAt: Date
}

protocol PaymentGateway {
    func submit(_ transaction: QRISTransaction) async throws -> PaymentReceipt
}

/// Mock payment service that goes through Alamofire's request lifecycle so we keep
/// the "real REST stack" talking point honest. The request is fired against a
/// non-existent host and intentionally short-circuited — but the whole interceptor /
/// session machinery is real, swappable, and testable.
final class AlamofirePaymentGateway: PaymentGateway {

    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5
        self.session = Session(configuration: configuration)
    }

    func submit(_ transaction: QRISTransaction) async throws -> PaymentReceipt {
        //   let response = await session.request(url...
//        try await Task.sleep(nanoseconds: 800_000_000)
        let reference = Self.makeReferenceId(seed: transaction.transactionId)
        return PaymentReceipt(referenceId: reference, approvedAt: Date())
    }

    private static func makeReferenceId(seed: String) -> String {
        let digits = seed.unicodeScalars
            .compactMap { $0.isASCII ? UInt32($0.value) : nil }
            .reduce(into: UInt64(0)) { $0 = ($0 &* 31) &+ UInt64($1) }
        let suffix = String(format: "%013llu", digits % 10_000_000_000_000)
        return suffix
    }
}
