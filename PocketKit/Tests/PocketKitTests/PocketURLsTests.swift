import XCTest
@testable import PocketKit

final class PocketURLsTests: XCTestCase {
    func test_pocketShareURL_whenURLIsNil_returnsNil() {
        let shareURL = pocketShareURL(nil, source: "")
        XCTAssertNil(shareURL)
    }

    func test_pocketShareURL_whenURLDoesNotContainUTMSource_returnsUpdatedURL() {
        let shareURL = pocketShareURL(URL(string: "https://getpocket.com/example")!, source: "tests")!
        let queryItems = URLComponents(url: shareURL, resolvingAgainstBaseURL: false)!.queryItems
        let source = queryItems!.first(where: { $0.name == "utm_source" })!
        XCTAssertEqual(source.value, "tests")
    }

    func test_pocketShareURL_whenURLContainsUTMSource_replacesSource() {
        let shareURL = pocketShareURL(URL(string: "https://getpocket.com/example?utm_source=foo")!, source: "tests")!
        let queryItems = URLComponents(url: shareURL, resolvingAgainstBaseURL: false)!.queryItems
        let source = queryItems!.first(where: { $0.name == "utm_source" })!
        XCTAssertEqual(source.value, "tests")
    }
}
