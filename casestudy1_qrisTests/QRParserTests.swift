import XCTest
@testable import casestudy1_qris

final class QRParserTests: XCTestCase {

    private let parser = DefaultQRParser()

    func testParsesValidQRISCode() {
        let result = parser.parse("BNI.ID12345678.MERCHANT MOCK TEST.50000")
        switch result {
        case .success(let tx):
            XCTAssertEqual(tx.bank, "BNI")
            XCTAssertEqual(tx.transactionId, "ID12345678")
            XCTAssertEqual(tx.merchantName, "MERCHANT MOCK TEST")
            XCTAssertEqual(tx.amount, 50_000)
        case .failure(let error):
            XCTFail("Expected success, got \(error)")
        }
    }

    func testRejectsEmptyString() {
        XCTAssertEqual(parser.parse(""), .failure(.empty))
        XCTAssertEqual(parser.parse("   "), .failure(.empty))
    }

    func testRejectsTooFewFields() {
        let result = parser.parse("BNI.ID123.MERCH")
        if case .failure(.wrongFieldCount(let expected, let actual)) = result {
            XCTAssertEqual(expected, 4)
            XCTAssertEqual(actual, 3)
        } else {
            XCTFail("Expected wrongFieldCount, got \(result)")
        }
    }

    func testRejectsTooManyFields() {
        let result = parser.parse("BNI.ID123.MERCH.50000.EXTRA")
        if case .failure(.wrongFieldCount(_, let actual)) = result {
            XCTAssertEqual(actual, 5)
        } else {
            XCTFail("Expected wrongFieldCount with 5 actual, got \(result)")
        }
    }

    func testRejectsUnknownBank() {
        let result = parser.parse("XYZBANK.ID1.MERCH.1000")
        if case .failure(.unknownBank(let name)) = result {
            XCTAssertEqual(name, "XYZBANK")
        } else {
            XCTFail("Expected unknownBank, got \(result)")
        }
    }

    func testNormalizesBankCasing() {
        let result = parser.parse("bni.ID1.MERCH.1000")
        if case .success(let tx) = result {
            XCTAssertEqual(tx.bank, "BNI")
        } else {
            XCTFail("Expected success with normalized bank, got \(result)")
        }
    }

    func testRejectsEmptyTransactionId() {
        XCTAssertEqual(parser.parse("BNI..MERCH.1000"), .failure(.invalidTransactionId))
    }

    func testRejectsEmptyMerchant() {
        XCTAssertEqual(parser.parse("BNI.ID1..1000"), .failure(.invalidMerchantName))
    }

    func testRejectsNonNumericAmount() {
        XCTAssertEqual(parser.parse("BNI.ID1.MERCH.NOTANUMBER"), .failure(.invalidAmount))
    }

    func testRejectsZeroAmount() {
        XCTAssertEqual(parser.parse("BNI.ID1.MERCH.0"), .failure(.nonPositiveAmount))
    }

    func testRejectsNegativeAmount() {
        XCTAssertEqual(parser.parse("BNI.ID1.MERCH.-500"), .failure(.nonPositiveAmount))
    }

    func testTrimsWhitespace() {
        let result = parser.parse("  BNI.ID1.MERCH.1000  \n")
        if case .success = result {} else { XCTFail("Expected success, got \(result)") }
    }

    func testAllSupportedBanksParse() {
        for bank in SupportedBank.allCases {
            let result = parser.parse("\(bank.rawValue).ID1.MERCH.1000")
            XCTAssertTrue({ if case .success = result { return true } else { return false } }(),
                          "Bank \(bank.rawValue) should be supported")
        }
    }
}
