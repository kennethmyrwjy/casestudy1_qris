import Foundation

protocol ScanInteracting: AnyObject {
    /// Pure business logic: takes a raw QR payload, returns either a domain
    /// transaction or a typed error. Safe to call from a background queue.
    func parse(_ raw: String) -> Result<QRISTransaction, QRParseError>
}

final class ScanInteractor: ScanInteracting {

    private let parser: QRParser

    init(parser: QRParser) {
        self.parser = parser
    }

    func parse(_ raw: String) -> Result<QRISTransaction, QRParseError> {
        parser.parse(raw)
    }
}
