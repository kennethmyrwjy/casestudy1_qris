import XCTest
@testable import casestudy1_qris

final class TransactionRepositoryTests: XCTestCase {

    private var repo: DefaultTransactionRepository!
    private var defaults: UserDefaults!
    private let suiteName = "qris.tests.history"

    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: suiteName)
        defaults = UserDefaults(suiteName: suiteName)!
        repo = DefaultTransactionRepository(defaults: defaults, key: "history")
    }

    override func tearDown() {
        UserDefaults().removePersistentDomain(forName: suiteName)
        repo = nil
        defaults = nil
        super.tearDown()
    }

    func testStartsEmpty() {
        XCTAssertTrue(repo.all().isEmpty)
    }

    func testAddPrependsRecord() {
        let first = makeRecord(merchant: "First", amount: 1000)
        let second = makeRecord(merchant: "Second", amount: 2000)
        repo.add(first)
        repo.add(second)
        let all = repo.all()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all.first?.merchantName, "Second")
    }

    func testPersistsAcrossInstances() {
        repo.add(makeRecord(merchant: "Persist", amount: 5000))
        let reloaded = DefaultTransactionRepository(defaults: defaults, key: "history")
        XCTAssertEqual(reloaded.all().count, 1)
        XCTAssertEqual(reloaded.all().first?.merchantName, "Persist")
    }

    func testClearRemovesAll() {
        repo.add(makeRecord(merchant: "A", amount: 100))
        repo.clear()
        XCTAssertTrue(repo.all().isEmpty)
    }

    private func makeRecord(merchant: String, amount: Int) -> PaymentRecord {
        PaymentRecord(
            bank: "BNI",
            transactionId: "ID1",
            merchantName: merchant,
            amount: amount,
            referenceId: "1234567890123",
            timestamp: Date()
        )
    }
}
