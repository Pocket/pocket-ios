import XCTest
@testable import SharedPocketKit

class PocketUserTests: XCTestCase {
    private var userDefaults: UserDefaults!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: "PocketUserTests")
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removePersistentDomain(forName: "PocketUserTests")
    }

    func subject(
        userDefaults: UserDefaults? = nil
    ) -> PocketUser {
        return PocketUser(
            userDefaults: userDefaults ?? self.userDefaults
        )
    }

    func test_setStatus_withPremiumTrue_setsPremiumStatus() {
        let user = subject()
        user.setPremiumStatus(true)
        XCTAssertEqual(user.status, .premium)
    }

    func test_setStatus_withPremiumFalse_setsFreeStatus() {
        let user = subject()
        user.setPremiumStatus(false)
        XCTAssertEqual(user.status, .free)
    }

    func test_clear_setsLoggedOutStatus() {
        let user = subject()
        user.clear()
        XCTAssertEqual(user.status, .unknown)
    }
}
