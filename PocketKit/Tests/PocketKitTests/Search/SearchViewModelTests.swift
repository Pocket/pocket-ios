import XCTest
import SharedPocketKit
import PocketGraph

@testable import Sync
@testable import PocketKit

class SearchViewModelTests: XCTestCase {
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var user: MockUser!
    private var userDefaults: UserDefaults!
    private var source: MockSource!
    private var space: Space!
    private var searchService: MockSearchService!

    override func setUpWithError() throws {
        networkPathMonitor = MockNetworkPathMonitor()
        user = MockUser()
        source = MockSource()
        userDefaults = UserDefaults(suiteName: "SearchViewModelTests")
        space = .testSpace()
        searchService = MockSearchService()
        source.stubMakeSearchService { self.searchService }
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removePersistentDomain(forName: "SearchViewModelTests")
        source = nil
        user = nil
        networkPathMonitor = nil
        try space.clear()
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
        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .saves)
        XCTAssertTrue(viewModel.emptyState is SearchEmptyState)
    }

    func test_updateScope_forFreeUser_withOnlineArchive_showsSearchEmptyState() {
        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is SearchEmptyState)
    }

    func test_updateScope_forFreeUser_withAll_showsGetPremiumEmptyState() {
        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .all)
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateScope_forPremiumUser_withSaves_showsRecentSearchEmptyState() {
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .saves)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withArchive_showsRecentSearchEmptyState() {
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withAll_showsRecentSearchEmptyState() {
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        XCTAssertTrue(viewModel.emptyState is RecentSearchEmptyState)
    }

    // MARK: Select Search Scope
    func test_updateScope_forFreeUser_withSavesAndTerm_showsResults() throws {
        try setupLocalSavesSearch()
        let viewModel = subject()
        viewModel.updateScope(with: .saves, searchTerm: "saved")

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])
    }

    func test_updateScope_forFreeUser_withArchiveAndTerm_showsResults() async {
        let term = "search-term"
        user.status = .free
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateScope(with: .archive, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_forFreeUser_withAllAndTerm_showsGetPremiumEmptyState() {
        let term = "search-term"

        let viewModel = subject()
        viewModel.updateScope(with: .all, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, [])
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateScope_forPremiumUser_withSavesAndTerm_showsResults() async {
        let term = "search-term"
        user.status = .premium
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateScope(with: .saves, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_forPremiumUser_withArchiveAndTerm_showsResults() async {
        let term = "search-term"
        user.status = .premium
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateScope(with: .archive, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_forPremiumUser_withAllAndTerm_showsResults() async {
        let term = "search-term"
        user.status = .premium
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateScope(with: .all, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    // MARK: - Update Search Results
    func test_updateSearchResults_forFreeUser_withNoItems_showsNoResultsEmptyState() {
        source.stubSearchItems { _ in return [] }
        let term = "search-term"
        let viewModel = subject()

        viewModel.updateSearchResults(with: term)
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forFreeUser_withItems_showsResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateScope(with: .archive)
        viewModel.updateSearchResults(with: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateSearchResults_forFreeUser_withAll_showsGetPremiumForAllItems() {
        let viewModel = subject()
        viewModel.updateScope(with: .all)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withNoItems_showsNoResultsEmptyState() async {
        user.status = .premium
        searchService.stubSearch { _, _ in }
        searchService._results = []

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withItems_showsResults() async {
        let term = "search-term"
        user.status = .premium
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateSearchResults(with: term)
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    // MARK: - Offline States
    func test_updateSearchResults_forFreeUser_withOfflineArchive_showsOfflineEmptyState() async {
        networkPathMonitor.update(status: .unsatisfied)
        let viewModel = subject()
        viewModel.updateScope(with: .archive, searchTerm: "search-term")

        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withOfflineArchive_showsOfflineEmptyState() async {
        user.status = .premium
        networkPathMonitor.update(status: .unsatisfied)
        await setupOnlineSearch(with: "search-term")

        let viewModel = subject()
        viewModel.updateScope(with: .archive, searchTerm: "search-term")

        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withOfflineAll_showsOfflineEmptyState() async {
        user.status = .premium
        networkPathMonitor.update(status: .unsatisfied)
        await setupOnlineSearch(with: "search-term")

        let viewModel = subject()
        viewModel.updateScope(with: .all, searchTerm: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    func test_selectingScope_whenOffline_showsOfflineEmptyState() async {
        user.status = .premium
        await setupOnlineSearch(with: "search-term")

        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        viewModel.updateScope(with: .all, searchTerm: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)

        viewModel.updateScope(with: .archive, searchTerm: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    // MARK: - Recent Searches
    func test_recentSearches_withFreeUser_hasNoRecentSearches() {
        user.status = .free
        source.stubSearchItems { _ in [] }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertEqual(viewModel.recentSearches, [])
    }

    func test_recentSearches_withNewTerm_showsRecentSearches() {
        user.status = .premium
        searchService.stubSearch { _, _ in }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertEqual(viewModel.recentSearches, ["search-term"])
    }

    func test_recentSearches_withDuplicateTerm_showsRecentSearches() {
        user.status = .premium
        searchService.stubSearch { _, _ in }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        viewModel.updateSearchResults(with: "Search-term")
        XCTAssertEqual(viewModel.recentSearches, ["search-term"])
    }

    func test_recentSearches_withEmptyTerm_showsRecentSearches() {
        user.status = .premium
        searchService.stubSearch { _, _ in }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "     ")
        XCTAssertEqual(viewModel.recentSearches, [])
    }

    func test_recentSearches_withNewTerms_showsMaxSearches() {
        user.status = .premium
        searchService.stubSearch { _, _ in }

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
        user.status = .premium
        searchService.stubSearch { _, _ in }

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

    // MARK: - Clear
    func test_clear_resetsSearchResults() async {
        let term = "search-term"
        user.status = .premium
        await setupOnlineSearch(with: term)

        let viewModel = subject()
        viewModel.updateSearchResults(with: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])

        viewModel.clear()

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, [])
    }

    private func setupLocalSavesSearch(with url: URL? = nil) throws {
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "saved-item-\($0)", givenURL: url)
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }
    }

    private func setupOnlineSearch(with term: String) async {
        searchService.stubSearch { _, _ in }
        let item = SearchSavedItemParts(data: DataDict([
            "__typename": "SavedItem",
            "item": [
                "__typename": "Item",
                "title": term,
                "givenUrl": "http://localhost:8080/hello",
                "resolvedUrl": "http://localhost:8080/hello"
            ]
        ], variables: nil))

        searchService._results = [item]
    }
}
