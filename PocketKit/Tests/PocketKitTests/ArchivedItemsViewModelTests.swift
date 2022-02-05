import XCTest
import Sync
import Combine
import Network
import Analytics

@testable import PocketKit


class ArchivedItemsViewModelTests: XCTestCase {
    var source: MockSource!
    var tracker: MockTracker!
    var networkMonitor: MockNetworkPathMonitor!
    var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        self.source = MockSource()
        self.tracker = MockTracker()
        self.networkMonitor = MockNetworkPathMonitor()
    }

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        networkMonitor: NetworkPathMonitor? = nil
    ) -> ArchivedItemsListViewModel {
        ArchivedItemsListViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            networkMonitor: networkMonitor ?? self.networkMonitor
        )
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
        let viewModel = subject()
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

    @MainActor
    func test_deleteAction_delegatesToSource_andUpdatesSnapshot() async throws {
        source.stubDelete { }
        source.stubFetchArchivedItems {
            [ArchivedItem.build(remoteID: "1"), ArchivedItem.build(remoteID: "2")]
        }

        let viewModel = subject()
        try await viewModel.fetch()

        viewModel.overflowActions(for: "1")?
            .first { $0.title == "Delete" }?
            .handler?(nil)


        let expectSnapshot = expectation(description: "expect a snapshot")
        viewModel.events.sink { event in
            guard case .snapshot(let snapshot) = event else {
                return
            }

            defer { expectSnapshot.fulfill() }
            XCTAssertFalse(snapshot.itemIdentifiers(inSection: .items).contains(.item("1")))
        }.store(in: &subscriptions)

        viewModel.presentedAlert?.actions.first { $0.title == "Yes" }?.invoke()

        wait(for: [expectSnapshot], timeout: 1)
        XCTAssertNotNil(source.deleteArchivedItemCall(at: 0))
    }
}
