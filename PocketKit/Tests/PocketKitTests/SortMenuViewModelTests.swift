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
        source = MockSource()
        tracker = MockTracker()
        listOptions = ListOptions()
        listOptions.selectedSort = .newest
    }
    
    override func tearDown() {
        subscriptions = []
    }

    private func subject(source: Source? = nil, tracker: Tracker? = nil, listOptions: ListOptions? = nil) -> SortMenuViewModel {
        return SortMenuViewModel(source: source ?? self.source,
                                 tracker: tracker ?? self.tracker,
                                 listOptions: listOptions ?? self.listOptions,
                                 sender: UIView())
    }
    
    func test_snapshot_containsAllSortOptions() {
        let sortMenuVM = subject()
        sortMenuVM.$snapshot.sink { snapshot in
            XCTAssertEqual(snapshot.sectionIdentifiers, [.sortBy])
            XCTAssertEqual(snapshot.itemIdentifiers(inSection: .sortBy), [.newest, .oldest])
        }.store(in: &subscriptions)
    }

    func test_cellViewModel_whenSortOptionIsSelected_returnsViewModelWithIsSelectedSetToTrue() {

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

    func test_select_setsTheSelectedSortOnListOptions() {
        
        listOptions.selectedSort = .oldest
        let sortMenuVM = subject()
        XCTAssert(listOptions.selectedSort == .oldest)

        sortMenuVM.select(row: .newest)

        XCTAssert(listOptions.selectedSort == .newest)
    }
}
