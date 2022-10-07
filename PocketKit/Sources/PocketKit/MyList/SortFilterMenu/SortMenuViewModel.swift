import UIKit
import Sync
import Analytics

enum SortMenuSourceView {
    case savedList
    case archiveList
}

class SortMenuViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<SortSection, SortOption>
    @Published
    private(set) var snapshot = Snapshot()

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
    }
}
