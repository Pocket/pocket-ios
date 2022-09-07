import UIKit
import Sync
import Analytics

class SortMenuViewModel {

    typealias Snapshot = NSDiffableDataSourceSnapshot<SortSection, SortOption>
    @Published
    private(set) var snapshot = Snapshot()

    private let source: Source
    private let tracker: Tracker
    private let listOptions: ListOptions
    let sender: Any

    init(source: Source, tracker: Tracker, listOptions: ListOptions, sender: Any) {
        self.source = source
        self.tracker = tracker
        self.listOptions = listOptions
        self.sender = sender
        buildSnapshot()
    }

    func buildSnapshot() {
        var snapshotTemp: NSDiffableDataSourceSnapshot<SortSection, SortOption> = .init()
        snapshotTemp.appendSections([.sortBy])
        snapshotTemp.appendItems([.newest, .oldest], toSection: .sortBy)
        snapshot = snapshotTemp
    }
}

extension SortMenuViewModel {

    func cellViewModel(for row: SortOption) -> SortMenuViewCell.Model {
        return .init(
            sortOption: row,
            isSelected: (listOptions.selectedSort == row)
        )
    }

    func select(row: SortOption) {
        listOptions.selectedSort = row
    }
}
