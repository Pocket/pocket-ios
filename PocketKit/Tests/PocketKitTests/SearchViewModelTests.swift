import XCTest
import Sync
import SharedPocketKit

@testable import PocketKit

class SearchViewModelTests: XCTestCase {
    var networkPathMonitor: MockNetworkPathMonitor!
    var user: MockUser!

    override func setUpWithError() throws {
        networkPathMonitor = MockNetworkPathMonitor()
        user = MockUser()
    }

    override func tearDownWithError() throws {
        networkPathMonitor = nil
        user = nil
    }

    func subject(
        networkPathMonitor: NetworkPathMonitor? = nil,
        user: User? = nil
    ) -> SearchViewModel {
        SearchViewModel(
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            user: user ?? self.user
        )
    }

    // MARK: - Update Scope
    func test_updateScope_forFreeUser_withOnlineSaves_showsSearchEmptyState() {
        let viewModel = subject()
        viewModel.updateScope(with: .saves)
        XCTAssertTrue(viewModel.emptyState is SearchEmptyState)
    }

    func test_updateScope_forFreeUser_withOnlineArchive_showsSearchEmptyState() {
        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is SearchEmptyState)
    }

    func test_updateScope_forFreeUser_withOfflineArchive_showsOfflineEmptyState() {
        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_updateScope_forFreeUser_withAll_showsGetPremiumEmptyState() {
        let viewModel = subject()
        viewModel.updateScope(with: .all)
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateScope_forPremiumUser_withSaves_showsRecentSearchEmptyState() {
        user.status = .premium

        let viewModel = subject()
        viewModel.updateScope(with: .saves)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withArchive_showsRecentSearchEmptyState() {
        user.status = .premium

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withOfflineArchive_showsOfflineEmptyState() {
        user.status = .premium
        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_updateScope_forPremiumUser_withAll_showsRecentSearchEmptyState() {
        user.status = .premium

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withOfflineAll_showsSearchEmptyState() {
        user.status = .premium
        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    // MARK: - Update Search Results
    func test_updateSearchResults_forFreeUser_afterSearch_showsNoResultsEmptyState() {
        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forFreeUser_afterSearch_showsGetPremiumForAllItems() {
        let viewModel = subject()
        viewModel.updateScope(with: .all)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withNoItems_showsNoResultsEmptyState() {
        user.status = .premium

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }
}
