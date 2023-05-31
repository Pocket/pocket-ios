// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Analytics
import Combine

@testable import Sync
@testable import PocketKit

class SortMenuViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var listOptions: ListOptions!
    private var subscriptions: [AnyCancellable] = []

    override func setUp() {
        super.setUp()
        source = MockSource()
        tracker = MockTracker()
        listOptions = .saved(userDefaults: .standard)
        listOptions.selectedSortOption = .newest
    }

    override func tearDown() {
        subscriptions = []
        super.tearDown()
    }

    private func subject(
        source: Source? = nil,
        tracker: Tracker? = nil,
        listOptions: ListOptions? = nil,
        listOfSortMenuOptions: [SortOption] = [.newest, .oldest, .shortestToRead, .longestToRead]
    ) -> SortMenuViewModel {
        return SortMenuViewModel(
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            listOptions: listOptions ?? self.listOptions,
            sender: UIView(),
            listOfSortMenuOptions: listOfSortMenuOptions
        )
    }

    func test_snapshot_containsAllSortOptionsForSavedItemsList() {
        let sortMenuVM = subject(
            listOfSortMenuOptions: [.newest, .oldest, .shortestToRead, .longestToRead]
        )
        sortMenuVM.$snapshot.sink { snapshot in
            XCTAssertEqual(snapshot.sectionIdentifiers, [.sortBy])
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .sortBy), [.newest, .oldest, .shortestToRead, .longestToRead])
        }.store(in: &subscriptions)
    }

    func test_cellViewModel_whenSortOptionIsSelected_returnsViewModelWithIsSelectedSetToTrue() {
        listOptions.selectedSortOption = .newest
        let sortMenuVM = subject()
        let sortCellModel = sortMenuVM.cellViewModel(for: SortOption.newest)

        XCTAssertEqual(sortCellModel.attributedTitle.string, "Newest saved")
        XCTAssertEqual(sortCellModel.isSelected, true)
    }

    func test_cellViewModel_whenGivenSortOptionIsNotSelected_returnsViewModelWithIsSelectedSetToFalse() {
        let sortMenuVM = subject()
        let sortCellModel = sortMenuVM.cellViewModel(for: SortOption.oldest)

        XCTAssertEqual(sortCellModel.attributedTitle.string, "Oldest saved")
        XCTAssertEqual(sortCellModel.isSelected, false)
    }

    func test_select_setsTheSelectedSortOnListOptionsForSavedList() {
        listOptions.selectedSortOption = .oldest
        let sortMenuVM = subject()
        XCTAssert(listOptions.selectedSortOption == .oldest)

        sortMenuVM.select(row: .newest)
        XCTAssert(listOptions.selectedSortOption == .newest)

        sortMenuVM.select(row: .shortestToRead)
        XCTAssert(listOptions.selectedSortOption == .shortestToRead)

        sortMenuVM.select(row: .longestToRead)
        XCTAssert(listOptions.selectedSortOption == .longestToRead)
    }
}
