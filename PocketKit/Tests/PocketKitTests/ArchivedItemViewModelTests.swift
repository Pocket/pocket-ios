import XCTest
import Sync
import Analytics
import Combine
@testable import PocketKit


class ArchivedItemViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
    }

    override func tearDown() {
        subscriptions = []
    }

    func test_init_buildsCorrectActions() {
        do {
            let viewModel = subject() // Unfavorited item

            let titles = viewModel.currentActions.map { $0.title }
            XCTAssertEqual(
                titles,
                ["Display Settings", "Save", "Favorite", "Delete", "Share"]
            )
        }

        do {
            let viewModel = subject(item: ArchivedItem.build(remoteID: "1", isFavorite: true)) // Favorited item

            let titles = viewModel.currentActions.map { $0.title }
            XCTAssertEqual(
                titles,
                ["Display Settings", "Save", "Unfavorite", "Delete", "Share"]
            )
        }
    }

    func test_displaySettings_updatesIsPresentingReaderSettings() {
        let viewModel = subject()
        viewModel.invokeAction(title: "Display Settings")
        XCTAssertEqual(viewModel.isPresentingReaderSettings, true)
    }

    func test_favorite_publishesAndUpdatesNewActions() {
        let viewModel = subject() // Unfavorited item

        // Drop first since we build actions on `init`
        // and only care about the favorite toggle
        let expectation = expectation(description: "correct actions on favorite")
        viewModel.actions.dropFirst(1).sink { actions in
            let titles = actions.map { $0.title }
            XCTAssertTrue(titles.contains("Unfavorite"))

            expectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectation], timeout: 1)
    }

    func test_favorite_sendsQueryToSource() {
        let expectation = expectation(description: "favorite called")
        source.stubFavoriteArchivedItem { _ in
            expectation.fulfill()
        }

        let item = ArchivedItem.build(remoteID: "1", isFavorite: false)
        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(source.favoriteArchivedItemCall(at: 0)?.item.remoteID, item.remoteID)
    }

    func test_favorite_onError_revertsAndPresentsAlert() {
        let item = ArchivedItem.build(remoteID: "1", isFavorite: false)
        let viewModel = subject(item: item)

        let expectFavoriteCall = expectation(description: "favorite called")
        source.stubFavoriteArchivedItem { _ in
            defer { expectFavoriteCall.fulfill() }
            throw FakeError.error
        }

        let expectNewActions = expectation(description: "new actions")
        viewModel.actions.dropFirst(2).sink { actions in
            expectNewActions.fulfill()
        }.store(in: &subscriptions)

        let expectAlert = expectation(description: "expect an alert")
        viewModel.$presentedAlert.dropFirst(1).sink { _ in
            expectAlert.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Favorite")
        wait(for: [expectFavoriteCall, expectNewActions, expectAlert], timeout: 1)

        XCTAssertTrue(viewModel.currentActions.map(\.title).contains("Favorite"))
        XCTAssertNotNil(viewModel.presentedAlert)
    }

    func test_unfavorite_sendsQueryToSource() {
        let expectation = expectation(description: "unfavorite called")
        source.stubUnfavoriteArchivedItem { _ in
            expectation.fulfill()
        }

        let item = ArchivedItem.build(remoteID: "1", isFavorite: true)
        let viewModel = subject(item: item)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(source.unfavoriteArchivedItemCall(at: 0)?.item.remoteID, item.remoteID)
    }

    func test_unfavorite_publishesAndUpdatesNewActions() {
        let viewModel = subject(item: .build(remoteID: "1", isFavorite: true)) // Favorited item

        // Drop first since we build actions on `init`
        // and only care about the favorite toggle
        let expectation = expectation(description: "correct actions on unfavorite")
        viewModel.actions.dropFirst(1).sink { actions in
            let titles = actions.map { $0.title }
            XCTAssertTrue(titles.contains("Favorite"))

            expectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectation], timeout: 1)
    }

    func test_unfavorite_onError_revertsAndPresentsAlert() {
        let item = ArchivedItem.build(remoteID: "1", isFavorite: true)
        let viewModel = subject(item: item)

        let expectUnfavoriteCall = expectation(description: "unfavorite called")
        source.stubUnfavoriteArchivedItem { _ in
            defer { expectUnfavoriteCall.fulfill() }
            throw FakeError.error
        }

        let expectNewActions = expectation(description: "new actions")
        viewModel.actions.dropFirst(2).sink { actions in
            expectNewActions.fulfill()
        }.store(in: &subscriptions)

        let expectAlert = expectation(description: "expect an alert")
        viewModel.$presentedAlert.dropFirst(1).sink { _ in
            expectAlert.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Unfavorite")
        wait(for: [expectUnfavoriteCall, expectNewActions, expectAlert], timeout: 1)

        XCTAssertTrue(viewModel.currentActions.map(\.title).contains("Unfavorite"))
        XCTAssertNotNil(viewModel.presentedAlert)
    }

    func test_delete_sendsDeleteEvent() {
        let viewModel = subject()

        let expectation = expectation(description: "delete event")
        viewModel.events.sink { event in
            guard case .delete = event else {
                XCTFail("expected delete event, got \(event) instead")
                return
            }

            expectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Delete")
        XCTAssertNotNil(viewModel.presentedAlert)

        viewModel.presentedAlert?.actions.first(where: { $0.title == "Yes" })?.invoke()

        wait(for: [expectation], timeout: 1)
    }

    func test_share_updatesSharedActivity() {
        let viewModel = subject()

        viewModel.invokeAction(title: "Share")

        XCTAssertNotNil(viewModel.sharedActivity)
    }

    func test_showWebReader_updatesPresentedWebReaderURL() {
        let viewModel = subject()
        viewModel.showWebReader()
        XCTAssertNotNil(viewModel.presentedWebReaderURL)
    }
}

extension ArchivedItemViewModelTests {
    private func subject(
        item: ArchivedItem = ArchivedItem.build(remoteID: "1", isFavorite: false),
        source: Source? = nil,
        tracker: Tracker? = nil
    ) -> ArchivedItemViewModel {
        return ArchivedItemViewModel(item: item, source: source ?? self.source, tracker: tracker ?? self.tracker)
    }
}

extension ArchivedItemViewModel {
    func invokeAction(title: String) {
        currentActions.first(where: { $0.title == title })?.handler?(nil)
    }
}
