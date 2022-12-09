import XCTest
import Sync
import SharedPocketKit
import PocketGraph

@testable import PocketKit

class SearchViewModelTests: XCTestCase {
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var user: MockUser!
    private var userDefaults: UserDefaults!
    private var source: MockSource!
    private var searchService: MockSearchService!

    override func setUpWithError() throws {
        networkPathMonitor = MockNetworkPathMonitor()
        user = MockUser()
        source = MockSource()
        userDefaults = UserDefaults(suiteName: "SearchViewModelTests")
        searchService = MockSearchService()

        source.stubMakeSearchService { self.searchService }
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removePersistentDomain(forName: "SearchViewModelTests")
        source = nil
        user = nil
        networkPathMonitor = nil
    }

    func subject(
        networkPathMonitor: NetworkPathMonitor? = nil,
        user: User? = nil,
        userDefaults: UserDefaults? = nil,
        source: Source? = nil
    ) -> SearchViewModel {
        SearchViewModel(
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            user: user ?? self.user,
            userDefaults: userDefaults ?? self.userDefaults,
            source: source ?? self.source
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

    func test_updateScope_forPremiumUser_withAll_showsRecentSearchEmptyState() {
        user.status = .premium

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    // MARK: - Update Search Results
    func test_updateSearchResults_forFreeUser_withNoItems_showsNoResultsEmptyState() {
        searchService.stubSearch { _, _ in }
        let term = "search-term"
        let viewModel = subject()

        searchService._results = []

        viewModel.updateSearchResults(with: term)
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forFreeUser_withItems_showsResults() {
        searchService.stubSearch { _, _ in }

        let term = "search-term"
        let item = SearchSavedItemParts(data: DataDict([
            "__typename": "SavedItem",
            "item": [
                "__typename": "Item",
                "title": term,
                "givenUrl": "http://localhost:8080/hello",
                "resolvedUrl": "http://localhost:8080/hello"
            ]
        ], variables: nil))
        user.status = .premium
        let viewModel = subject()
        searchService.stubSearch { _, _ in
            viewModel.searchResults = [SearchItem(item: item)]
        }

        viewModel.updateSearchResults(with: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title }, ["search-term"])
        XCTAssertNil(viewModel.emptyState)
    }

    func test_updateSearchResults_forFreeUser_withAll_showsGetPremiumForAllItems() {
        searchService.stubSearch { _, _ in }

        let viewModel = subject()
        viewModel.updateScope(with: .all)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withNoItems_showsNoResultsEmptyState() {
        searchService.stubSearch { _, _ in }

        user.status = .premium
        let viewModel = subject()

        searchService._results = []
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withItems_showsResults() {
        let term = "search-term"
        let item = SearchSavedItemParts(data: DataDict([
            "__typename": "SavedItem",
            "item": [
                "__typename": "Item",
                "title": term,
                "givenUrl": "http://localhost:8080/hello",
                "resolvedUrl": "http://localhost:8080/hello"
            ]
        ], variables: nil))
        user.status = .premium
        let viewModel = subject()

        searchService.stubSearch { _, _ in
            viewModel.searchResults = [SearchItem(item: item)]
        }

        viewModel.updateSearchResults(with: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title }, ["search-term"])
        XCTAssertNil(viewModel.emptyState)
    }

    // MARK: - Offline States
    func test_updateSearchResults_forFreeUser_withOfflineArchive_showsOfflineEmptyState() {
        searchService.stubSearch { _, _ in }
        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withOfflineArchive_showsOfflineEmptyState() {
        searchService.stubSearch { _, _ in }
        user.status = .premium
        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withOfflineAll_showsOfflineEmptyState() {
        searchService.stubSearch { _, _ in }
        user.status = .premium
        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = subject()
        viewModel.updateScope(with: .all)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    // MARK: - Recent Searches
    func test_recentSearches_withFreeUser_hasNoRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .free

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertEqual(viewModel.recentSearches, [])
    }

    func test_recentSearches_withNewTerm_showsRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertEqual(viewModel.recentSearches, ["search-term"])
    }

    func test_recentSearches_withDuplicateTerm_showsRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        viewModel.updateSearchResults(with: "Search-term")
        XCTAssertEqual(viewModel.recentSearches, ["search-term"])
    }

    func test_recentSearches_withEmptyTerm_showsRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        let viewModel = subject()
        viewModel.updateSearchResults(with: "     ")
        XCTAssertEqual(viewModel.recentSearches, [])
    }

    func test_recentSearches_withNewTerms_showsMaxSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term-1")
        viewModel.updateSearchResults(with: "search-term-2")
        viewModel.updateSearchResults(with: "search-term-3")
        viewModel.updateSearchResults(with: "search-term-4")
        viewModel.updateSearchResults(with: "search-term-5")
        viewModel.updateSearchResults(with: "search-term-6")

        XCTAssertEqual(viewModel.recentSearches, ["search-term-2", "search-term-3", "search-term-4", "search-term-5", "search-term-6"])
    }

    func test_recentSearches_withPreviousSearch_updatesSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term-1")
        viewModel.updateSearchResults(with: "search-term-2")
        viewModel.updateSearchResults(with: "search-term-3")
        viewModel.updateSearchResults(with: "search-term-4")
        viewModel.updateSearchResults(with: "search-term-5")
        viewModel.updateSearchResults(with: "search-term-6")
        viewModel.updateSearchResults(with: "search-term-2")

        XCTAssertEqual(viewModel.recentSearches, ["search-term-3", "search-term-4", "search-term-5", "search-term-6", "search-term-2"])
    }
}
