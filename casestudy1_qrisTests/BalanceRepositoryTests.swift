import XCTest
@testable import casestudy1_qris

final class BalanceRepositoryTests: XCTestCase {

    private var repo: DefaultBalanceRepository!
    private let testService = "qris.tests.balance"

    override func setUp() {
        super.setUp()
        // Clear any leftover state from previous runs.
        KeychainStore(service: testService).removeAll()
        repo = DefaultBalanceRepository(
            store: KeychainStore(service: testService),
            seedBalance: 1_000_000
        )
    }

    override func tearDown() {
        KeychainStore(service: testService).removeAll()
        repo = nil
        super.tearDown()
    }

    func testSeedsBalanceOnFirstLaunch() {
        XCTAssertEqual(repo.currentBalance(), 1_000_000)
    }

    func testDeductReducesBalance() throws {
        let remaining = try repo.deduct(250_000)
        XCTAssertEqual(remaining, 750_000)
        XCTAssertEqual(repo.currentBalance(), 750_000)
    }

    func testDeductFailsWhenInsufficient() {
        XCTAssertThrowsError(try repo.deduct(2_000_000)) { error in
            guard case BalanceError.insufficientFunds(let balance, let required) = error else {
                return XCTFail("Expected insufficientFunds, got \(error)")
            }
            XCTAssertEqual(balance, 1_000_000)
            XCTAssertEqual(required, 2_000_000)
        }
        XCTAssertEqual(repo.currentBalance(), 1_000_000, "Balance must be unchanged after failed deduct")
    }

    func testBalancePersistsAcrossInstances() throws {
        try repo.deduct(300_000)
        let reloaded = DefaultBalanceRepository(
            store: KeychainStore(service: testService),
            seedBalance: 1_000_000
        )
        XCTAssertEqual(reloaded.currentBalance(), 700_000)
    }

    func testResetOverwritesBalance() {
        repo.reset(to: 5_000_000)
        XCTAssertEqual(repo.currentBalance(), 5_000_000)
    }
}
