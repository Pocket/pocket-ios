import XCTest

@testable import Sync
@testable import PocketKit

class RouterTests: XCTestCase {
    private var space: Space!
    private var source: MockSource!

    override func setUpWithError() throws {
        source = MockSource()
        space = .testSpace()
    }

    override func tearDownWithError() throws {
        try space.clear()
    }

    func subject(source: Source? = nil) -> Router {
        Router(source: source ?? self.source)
    }

    func test_handleURL_forSavingURL_savesItem() throws {
        source.stubSaveURL { _ in }
        guard let url = URL(string: "https://getpocket.com/add?url=https%3A%2F%2Fen.wikipedia.org%2Fwiki%2FDuck") else {
            XCTFail("should not be nil")
            return
        }
        let router = subject()
        router.handle(url: url)
        XCTAssertEqual(source.saveURLCall(at: 0)?.url.absoluteString, "https://en.wikipedia.org/wiki/Duck")
    }
}
