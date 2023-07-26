// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Sync
import Combine

@testable import PocketKit
@testable import Sync

class CollectionViewModelTests: XCTestCase {
    private var source: MockSource!
    private var space: Space!

    private var subscriptions: Set<AnyCancellable> = []

    override func setUp() {
        super.setUp()
        source = MockSource()
        space = .testSpace()
    }

    override func tearDownWithError() throws {
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        slug: String,
        source: Source? = nil
    ) -> CollectionViewModel {
        CollectionViewModel(slug: slug, source: source ?? self.source)
    }

    func test_archive_sendsRequestToSource_andSendsArchiveEvent() {
        let item = space.buildSavedItem().item
        let collection = setupCollection(with: item)
        let viewModel = subject(slug: collection.slug)

        let expectArchive = expectation(description: "expect source.archive(_:)")
        source.stubArchiveSavedItem { archivedSavedItem in
            defer { expectArchive.fulfill() }
            XCTAssertTrue(archivedSavedItem === item?.savedItem)
        }

        let expectArchiveEvent = expectation(description: "expect archive event")
        viewModel.events.dropFirst().sink { event in
            guard case .archive = event else {
                XCTFail("Received unexpected event: \(String(describing: event))")
                return
            }

            expectArchiveEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.archive()
        wait(for: [expectArchive, expectArchiveEvent], timeout: 1)
    }

    func test_moveToSaves_withSavedItem_sendsRequestToSource_AndRefreshes() {
        let item = space.buildSavedItem().item
        let collection = setupCollection(with: item)
        let viewModel = subject(slug: collection.slug)

        let expectMoveToSaves = expectation(description: "expect source.unarchive(_:)")
        source.stubUnarchiveSavedItem { unarchivedSavedItem in
            defer { expectMoveToSaves.fulfill() }
            XCTAssertTrue(unarchivedSavedItem === item?.savedItem)
        }

        viewModel.moveToSaves { _ in }

        wait(for: [expectMoveToSaves], timeout: 1)
    }

    func test_moveToSaves_withoutSavedItem_sendsRequestToSource_AndRefreshes() {
        let collection = setupCollection(with: nil)
        let viewModel = subject(slug: collection.slug)

        let expectMoveToSaves = expectation(description: "expect source.url(_:)")
        source.stubSaveURL { url in
            defer { expectMoveToSaves.fulfill() }
            XCTAssertEqual(url, "https://getpocket.com/collections/slug-1")
        }

        viewModel.moveToSaves { _ in }

        wait(for: [expectMoveToSaves], timeout: 1)
    }

    func test_savedCollection_buildsCorrectActions() {
        // not-favorited, not-archived
        let item = space.buildSavedItem(isFavorite: false, isArchived: false).item
        let collection = setupCollection(with: item)

        let viewModel = subject(slug: collection.slug)
        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Favorite", "Add tags", "Delete", "Share"]
        )

        // favorited
        item?.savedItem?.isFavorite = true

        XCTAssertEqual(
            viewModel._actions.map(\.title),
            ["Unfavorite", "Add tags", "Delete", "Share"]
        )
    }

    func test_favorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: false).item
        let collection = setupCollection(with: item)

        let expectFavorite = expectation(description: "expect source.favorite(_:)")

        source.stubFavoriteSavedItem { favoritedSavedItem in
            defer { expectFavorite.fulfill() }
            XCTAssertTrue(favoritedSavedItem.item === item)
            XCTAssertTrue(favoritedSavedItem === item?.savedItem)
        }

        let viewModel = subject(slug: collection.slug)
        viewModel.invokeAction(title: "Favorite")

        wait(for: [expectFavorite], timeout: 1)
    }

    func test_unfavorite_delegatesToSource() {
        let item = space.buildSavedItem(isFavorite: true).item
        let collection = setupCollection(with: item)

        let expectUnfavorite = expectation(description: "expect source.unfavorite(_:)")

        source.stubUnfavoriteSavedItem { unfavoritedSavedItem in
            defer { expectUnfavorite.fulfill() }
            XCTAssertTrue(unfavoritedSavedItem.item === item)
            XCTAssertTrue(unfavoritedSavedItem === item?.savedItem)
        }

        let viewModel = subject(slug: collection.slug)
        viewModel.invokeAction(title: "Unfavorite")

        wait(for: [expectUnfavorite], timeout: 1)
    }

    func test_delete_delegatesToSource_andSendsDeleteEvent() {
        let item = space.buildSavedItem(isFavorite: true).item
        let collection = setupCollection(with: item)
        let viewModel = subject(slug: collection.slug)

        let expectDelete = expectation(description: "expect source.delete(_:)")
        source.stubDeleteSavedItem { deletedSavedItem in
            defer { expectDelete.fulfill() }
            XCTAssertTrue(deletedSavedItem.item === item)
        }

        let expectDeleteEvent = expectation(description: "expect delete event")
        viewModel.events.dropFirst().sink { event in
            guard case .delete = event else {
                XCTFail("Received unexpected event: \(String(describing: event))")
                return
            }

            expectDeleteEvent.fulfill()
        }.store(in: &subscriptions)

        viewModel.invokeAction(title: "Delete")
        viewModel.presentedAlert?.actions.first { $0.title == "Yes" }?.invoke()

        wait(for: [expectDelete, expectDeleteEvent], timeout: 1)
    }

    private func setupCollection(with item: Item?) -> Collection {
        let story = space.buildCollectionStory(item: item)

        source.stubFetchItem { url in
            return item
        }

        return space.buildCollection(stories: [story])
    }
}

extension CollectionViewModel {
    func invokeAction(title: String) {
        invokeAction(from: _actions, title: title)
    }

    func invokeAction(from actions: [ItemAction], title: String) {
        actions.first(where: { $0.title == title })?.handler?(nil)
    }
}
