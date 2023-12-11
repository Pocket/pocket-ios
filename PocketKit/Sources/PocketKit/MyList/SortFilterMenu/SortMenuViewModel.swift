// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Analytics

enum SortMenuSourceView {
    case savedList
    case archiveList
}

class SortMenuViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<SortSection, SortOption>
    @Published private(set) var snapshot = Snapshot()

    private let source: Source
    private let tracker: Tracker
    private let listOptions: ListOptions
    private let listOfSortMenuOptions: [SortOption]
    let sender: Any

    init(
        source: Source,
        tracker: Tracker,
        listOptions: ListOptions,
        sender: Any,
        listOfSortMenuOptions: [SortOption] = [.newest, .oldest, .shortestToRead, .longestToRead]
    ) {
        self.source = source
        self.tracker = tracker
        self.listOptions = listOptions
        self.sender = sender
        self.listOfSortMenuOptions = listOfSortMenuOptions
        buildSnapshot()
    }

    func buildSnapshot() {
        var snapshotTemp: NSDiffableDataSourceSnapshot<SortSection, SortOption> = .init()
        snapshotTemp.appendSections([.sortBy])
        snapshotTemp.appendItems(listOfSortMenuOptions, toSection: .sortBy)
        snapshot = snapshotTemp
    }
}

extension SortMenuViewModel {
    func cellViewModel(for row: SortOption) -> SortMenuViewCell.Model {
        return .init(
            sortOption: row,
            isSelected: listOptions.selectedSortOption == row
        )
    }

    func select(row: SortOption) {
        guard listOfSortMenuOptions.contains(row) else {
            return
        }

        listOptions.selectedSortOption = row
        track(sortOption: row)
    }

    private func track(sortOption: SortOption) {
        let selection = UIContext(type: .button, identifier: sortOption.uiContextIdentifier)
        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, [selection])
    }
}

extension SortOption {
    var uiContextIdentifier: UIContext.Identifier {
        switch self {
        case .newest: return .sortByNewest
        case .oldest: return .sortByOldest
        case .longestToRead: return .sortByLongest
        case .shortestToRead: return .sortByShortest
        }
    }
}
