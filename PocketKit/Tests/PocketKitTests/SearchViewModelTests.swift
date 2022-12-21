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
        try setupLocalSearch()
        let viewModel = subject()
        viewModel.updateScope(with: .saves, searchTerm: "saved")

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])
    }

    func test_updateScope_forFreeUser_withArchiveAndTerm_showsResults() {
        let term = "search-term"
        user.status = .free

        let viewModel = subject()
        setupOnlineSearch(with: term, for: viewModel)
        viewModel.updateScope(with: .archive, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_forFreeUser_withAllAndTerm_showsGetPremiumEmptyState() {
        let term = "search-term"

        let viewModel = subject()
        setupOnlineSearch(with: term, for: viewModel)
        viewModel.updateScope(with: .all, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, [])
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateScope_forPremiumUser_withSavesAndTerm_showsResults() throws {
        let term = "search-term"
        user.status = .premium

        let viewModel = subject()
        setupOnlineSearch(with: term, for: viewModel)
        viewModel.updateScope(with: .saves, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_forPremiumUser_withArchiveAndTerm_showsResults() {
        let term = "search-term"
        user.status = .premium

        let viewModel = subject()
        setupOnlineSearch(with: term, for: viewModel)
        viewModel.updateScope(with: .archive, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_forPremiumUser_withAllAndTerm_showsResults() {
        let term = "search-term"
        user.status = .premium

        let viewModel = subject()
        setupOnlineSearch(with: term, for: viewModel)
        viewModel.updateScope(with: .all, searchTerm: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_withSaves_showsCachedResults() throws {
        let viewModel = subject()
        try setupLocalSearch()
        viewModel.updateScope(with: .saves, searchTerm: "search-term")
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])

        viewModel.searchResults = []

        viewModel.updateScope(with: .saves, searchTerm: "search-term")
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])
    }

    func test_updateScope_withArchive_showsCachedResults() {
        user.status = .premium
        let viewModel = subject()
        setupOnlineSearch(with: "search-term", for: viewModel)
        viewModel.updateScope(with: .archive, searchTerm: "search-term")
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])

        viewModel.searchResults = []

        viewModel.updateScope(with: .archive, searchTerm: "search-term")
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateScope_withAll_showsCachedResults() {
        user.status = .premium
        let viewModel = subject()
        setupOnlineSearch(with: "search-term", for: viewModel)
        viewModel.updateScope(with: .all, searchTerm: "search-term")
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])

        viewModel.searchResults = []

        viewModel.updateScope(with: .all, searchTerm: "search-term")
        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    // MARK: - Update Search Results
    func test_updateSearchResults_forFreeUser_withNoItems_showsNoResultsEmptyState() {
        source.stubSearchItems { _ in return [] }
        searchService.stubSearch { _, _ in }
        let term = "search-term"

        let viewModel = subject()

        searchService._results = []

        viewModel.updateSearchResults(with: term)
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forFreeUser_withItems_showsResults() {
        let term = "search-term"

        let viewModel = subject()
        setupOnlineSearch(with: term, for: viewModel)
        viewModel.updateScope(with: .archive)
        viewModel.updateSearchResults(with: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
    }

    func test_updateSearchResults_forFreeUser_withAll_showsGetPremiumForAllItems() {
        searchService.stubSearch { _, _ in }
        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateScope(with: .all)
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is GetPremiumEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withNoItems_showsNoResultsEmptyState() {
        searchService.stubSearch { _, _ in }
        source.stubSearchItems { _ in return [] }

        user.status = .premium

        let viewModel = subject()

        searchService._results = []
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertTrue(viewModel.emptyState is NoResultsEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withItems_showsResults() {
        let term = "search-term"
        user.status = .premium

        let viewModel = subject()
        setupOnlineSearch(with: "search-term", for: viewModel)

        viewModel.updateSearchResults(with: term)

        XCTAssertEqual(viewModel.searchResults?.compactMap { $0.title.string }, ["search-term"])
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

    func test_selectingScope_whenOffline_showsOfflineEmptyState() {
        searchService.stubSearch { _, _ in }
        user.status = .premium
        let viewModel = subject()
        networkPathMonitor.update(status: .unsatisfied)

        viewModel.updateScope(with: .all, searchTerm: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
        viewModel.updateScope(with: .archive, searchTerm: "search-term")
        XCTAssertTrue(viewModel.emptyState is OfflineEmptyState)
    }

    // MARK: - Recent Searches
    func test_recentSearches_withFreeUser_hasNoRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .free

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertEqual(viewModel.recentSearches, [])
    }

    func test_recentSearches_withNewTerm_showsRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        XCTAssertEqual(viewModel.recentSearches, ["search-term"])
    }

    func test_recentSearches_withDuplicateTerm_showsRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "search-term")
        viewModel.updateSearchResults(with: "Search-term")
        XCTAssertEqual(viewModel.recentSearches, ["search-term"])
    }

    func test_recentSearches_withEmptyTerm_showsRecentSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.updateSearchResults(with: "     ")
        XCTAssertEqual(viewModel.recentSearches, [])
    }

    func test_recentSearches_withNewTerms_showsMaxSearches() {
        searchService.stubSearch { _, _ in }
        user.status = .premium

        source.stubSearchItems { _ in return [] }

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

        source.stubSearchItems { _ in return [] }

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

    // MARK: - Local Saves Searches
    func test_savesSearches_withFreeUser_showSearchResults_searchTitle() throws {
        user.status = .free

        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "saved-item-\($0)")
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "saved")
        XCTAssertEqual(viewModel.searchResults?.count, 2)

        source.stubSearchItems { _ in return [] }

        viewModel.submitLocalSearch(with: "none")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        try space.clear()
    }

    func test_savesSearches_withPremiumUser_showSearchResults_searchTitle() throws {
        user.status = .premium

        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "saved-item-\($0)")
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "saved")
        XCTAssertEqual(viewModel.searchResults?.count, 2)

        source.stubSearchItems { _ in return [] }

        viewModel.submitLocalSearch(with: "none")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        try space.clear()
    }

    func test_savesSearches_withFreeUser_showSearchResults_searchUrl() throws {
        user.status = .free

        let url = URL(string: "testUrl.saved")
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "=item-\($0)", givenURL: url)
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "saved")
        XCTAssertEqual(viewModel.searchResults?.count, 2)

        source.stubSearchItems { _ in return [] }

        viewModel.submitLocalSearch(with: "none")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        try space.clear()
    }

    func test_savesSearches_withPremiumUser_showSearchResults_searchUrl() throws {
        user.status = .premium

        let url = URL(string: "testUrl.saved")
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "item-\($0)", givenURL: url)
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "saved")
        XCTAssertEqual(viewModel.searchResults?.count, 2)

        source.stubSearchItems { _ in return [] }

        viewModel.submitLocalSearch(with: "none")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        try space.clear()
    }

    func test_savesSearches_withFreeUser_showSearchResults_doesNotSearchTag() throws {
        user.status = .free

        _ = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                tags: ["test"]
            )
        }
        try space.save()

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "saved")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        viewModel.submitLocalSearch(with: "test")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        viewModel.submitLocalSearch(with: "none")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        try space.clear()
    }

    func test_savesSearches_withPremiumUser_showSearchResults_searchTag() throws {
        user.status = .premium

        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                tags: ["test"]
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "test")
        XCTAssertEqual(viewModel.searchResults?.count, 2)

        source.stubSearchItems { _ in return [] }

        viewModel.submitLocalSearch(with: "saved")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        viewModel.submitLocalSearch(with: "none")
        XCTAssertEqual(viewModel.searchResults?.isEmpty, true)

        try space.clear()
    }

    func test_savesSearches_testSourceWithSearchTerm() throws {
        user.status = .premium

        source.stubSearchItems { _ in return [] }

        let viewModel = subject()
        viewModel.submitLocalSearch(with: "test")
        XCTAssertTrue(source.searchSavesCall(at: 0)?.searchTerm == "test")

        viewModel.submitLocalSearch(with: "none")
        XCTAssertTrue(source.searchSavesCall(at: 1)?.searchTerm == "none")
    }

    private func setupOnlineSearch(with term: String, for viewModel: SearchViewModel) {
        let item = SearchSavedItemParts(data: DataDict([
            "__typename": "SavedItem",
            "item": [
                "__typename": "Item",
                "title": term,
                "givenUrl": "http://localhost:8080/hello",
                "resolvedUrl": "http://localhost:8080/hello"
            ]
        ], variables: nil))

        searchService.stubSearch { _, _ in
            viewModel.searchResults = [SearchItem(item: item)]
        }
    }

    private func setupLocalSearch() throws {
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "saved-item-\($0)")
            )
        }
        try space.save()

        source.stubSearchItems { _ in return savedItems }
    }
}
