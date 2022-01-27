import XCTest
import Sync
import Combine
@testable import PocketKit


class ArchiveViewModelTests: XCTestCase {
    var source: MockSource!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        self.source = MockSource()
    }

    override func tearDown() {
        subscriptions = []
    }

    func test_fetch_returnsArchivedItemsFromSource() async throws {
//        let archivedItems = [
//            ArchivedItem.build(remoteID: "1"),
//            ArchivedItem.build(remoteID: "2")
//        ]
//
//        source.stubFetchArchivedItems {
//            return archivedItems
//        }
//
//        let expectEvent = expectation(description: "wait for an event")
//        let viewModel = ArchiveViewModel(source: source)
//        viewModel.events.sink { event in
//            guard case .snapshot(let snapshot) = event else {
//                XCTFail("Expected a snapshot event")
//                return
//            }
//
//            XCTAssertEqual(snapshot.itemIdentifiers, archivedItems.map(\.remoteID))
//            expectEvent.fulfill()
//        }.store(in: &subscriptions)
//
//        try await viewModel.fetch()
//        wait(for: [expectEvent], timeout: 1)
//
//        XCTAssertEqual(
//            viewModel.archivedItem(id: "1"),
//            archivedItems[0]
//        )
    }
}
