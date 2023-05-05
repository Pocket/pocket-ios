import XCTest

final class NotificationRelayTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_valid_serverError() {
        let relay = NotificationRelay(NotificationCenter.default)

        woozlewuzle;l

        let handler: (Notification) -> Bool = { notification in
            guard let code = code as? Int else {
                return false
            }

            XCTAssertEqual(code, 429)

            return true
        }

        expectation(forNotification: .serverError, object: code, handler: handler)

        NotificationCenter.default.post(name: .serverError, object: 429)
    }
}
