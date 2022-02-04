import XCTest
import Sync
import Combine
@testable import PocketKit


class ArchivedItemsViewModelTests: XCTestCase {
    var source: MockSource!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        self.source = MockSource()
    }

    override func tearDown() {
        subscriptions = []
    }

    func test_fetch_returnsArchivedItemsFromSource() async throws {
        let archivedItems = [
            ArchivedItem.build(remoteID: "1"),
            ArchivedItem.build(remoteID: "2")
        ]

        source.stubFetchArchivedItems {
            return archivedItems
        }

        let expectEvent = expectation(description: "wait for an event")
        let viewModel = ArchivedItemsListViewModel(
            source: source,
            tracker: MockTracker()
        )
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                XCTFail("Expected a snapshot event")
                return
            }

            guard !snapshot.itemIdentifiers(inSection: .items).isEmpty else {
                return
            }

            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .items), [.item("1"), .item("2")])
            expectEvent.fulfill()
        }.store(in: &subscriptions)

        try await viewModel.fetch()
        wait(for: [expectEvent], timeout: 1)

        XCTAssertEqual(
            viewModel.item(with: "1")?.attributedTitle.string,
            "http://example.com"
        )
    }
}
