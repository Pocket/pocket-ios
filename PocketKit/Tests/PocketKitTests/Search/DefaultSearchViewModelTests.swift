// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import SharedPocketKit
import PocketGraph
import Analytics
import Combine
import Apollo

@testable import Sync
@testable import PocketKit

class DefaultSearchViewModelTests: XCTestCase {
    private var networkPathMonitor: MockNetworkPathMonitor!
    private var userDefaults: UserDefaults!
    private var source: MockSource!
    private var space: Space!
    private var searchService: MockSearchService!
    private var tracker: MockTracker!
    private var subscriptions: [AnyCancellable] = []
    private var subscriptionStore: SubscriptionStore!
    private var itemsController: MockSavedItemsController!
    private var notificationCenter: NotificationCenter!
    private var featureFlags: MockFeatureFlagService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        networkPathMonitor = MockNetworkPathMonitor()
        source = MockSource()
        tracker = MockTracker()
        userDefaults = UserDefaults(suiteName: "SearchViewModelTests")
        featureFlags = MockFeatureFlagService()
        space = .testSpace()
        notificationCenter = .default
        searchService = MockSearchService()
        source.stubMakeSearchService { self.searchService }

        subscriptionStore = MockSubscriptionStore()

        itemsController = MockSavedItemsController()
        itemsController.stubIndexPathForObject { _ in IndexPath(item: 0, section: 0) }
        source.stubMakeSavesController {
            self.itemsController
        }
        itemsController.stubPerformFetch {
            self.itemsController.fetchedObjects = []
        }
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removePersistentDomain(forName: "SearchViewModelTests")
        source = nil
        networkPathMonitor = nil
        subscriptions = []
        subscriptionStore = nil
        try space.clear()
        try super.tearDownWithError()
    }

    func subject(
        networkPathMonitor: NetworkPathMonitor? = nil,
        user: User,
        userDefaults: UserDefaults? = nil,
        featureFlags: FeatureFlagServiceProtocol? = nil,
        source: Source? = nil,
        tracker: Tracker? = nil,
        notificationCenter: NotificationCenter? = nil
    ) async -> DefaultSearchViewModel {
        let premiumViewModel = PremiumUpgradeViewModel(
            store: subscriptionStore,
            tracker: MockTracker(),
            source: .search,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor
        )
        return DefaultSearchViewModel(
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            user: user,
            userDefaults: userDefaults ?? self.userDefaults,
            featureFlags: featureFlags ?? self.featureFlags,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            store: subscriptionStore ?? self.subscriptionStore,
            notificationCenter: notificationCenter ?? self.notificationCenter,
            premiumUpgradeViewModelFactory: {_ in
                premiumViewModel
            }
        )
    }

    // MARK: - Update Scope
    func test_updateScope_forFreeUser_withOnlineSaves_showsSearchEmptyState() async {
        source.stubSearchItems { _ in return [] }
        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .saves)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is SearchEmptyState)
    }

    func test_updateScope_forFreeUser_withOnlineArchive_showsSearchEmptyState() async {
        source.stubSearchItems { _ in return [] }

        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .archive)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is SearchEmptyState)
    }

    func test_updateScope_forFreeUser_withAll_showsGetPremiumEmptyState() async {
        source.stubSearchItems { _ in return [] }

        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .all)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is GetPremiumEmptyState)
    }

    func test_updateScope_forPremiumUser_withSaves_showsRecentSearchEmptyState() async {
        source.stubSearchItems { _ in return [] }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateScope(with: .saves)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withArchive_showsRecentSearchEmptyState() async {
        source.stubSearchItems { _ in return [] }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateScope(with: .archive)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is RecentSearchEmptyState)
    }

    func test_updateScope_forPremiumUser_withAll_showsRecentSearchEmptyState() async {
        source.stubSearchItems { _ in return [] }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateScope(with: .all)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is RecentSearchEmptyState)
    }

    // MARK: Select Search Scope
    func test_updateScope_forFreeUser_withSavesAndTerm_showsResults() async throws {
        try setupLocalSavesSearch()
        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .saves, searchTerm: "saved")

        guard case .searchResults(let results) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }

        XCTAssertEqual(results.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])
    }

    func test_updateScope_forFreeUser_withArchiveAndTerm_showsResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)
        let viewModel = await subject(user: MockUser(status: .free))

        let searchExpectation = expectation(description: "search Expectation")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .archive, searchTerm: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    func test_updateScope_forFreeUser_withAllAndTerm_showsGetPremiumEmptyState() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .all, searchTerm: term)

        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is GetPremiumEmptyState)
    }

    func test_updateScope_forPremiumUser_withSavesAndTerm_showsResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))

        let searchExpectation = expectation(description: "search Expectation")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .saves, searchTerm: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    func test_updateScope_forPremiumUser_withArchiveAndTerm_showsResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))
        let searchExpectation = expectation(description: "search Expectation")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .archive, searchTerm: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    func test_updateScope_forPremiumUser_withAllAndTerm_showsResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))
        let searchExpectation = expectation(description: "search Expectation")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .all, searchTerm: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    // MARK: - Update Search Results
    func test_updateSearchResults_forFreeUser_withNoItems_showsNoResultsEmptyState() async {
        source.stubSearchItems { _ in return [] }
        let term = "search-term"
        let user = MockUser()
        let viewModel = await subject(user: user)

        viewModel.updateSearchResults(with: term)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is NoResultsEmptyState)
    }

    func test_updateSearchResults_forFreeUser_withItems_showsResults() async throws {
        let term = "search-term"
        try setupLocalSavesSearch()

        let user = MockUser()
        let viewModel = await subject(user: user)

        viewModel.updateSearchResults(with: term)

        guard case .searchResults(let results) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }

        XCTAssertEqual(results.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])
    }

    func test_updateSearchResults_forFreeUser_withAll_showsGetPremiumForAllItems() async {
        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .all)
        viewModel.updateSearchResults(with: "search-term")

        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is GetPremiumEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withNoItems_showsNoResultsEmptyState() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))
        let searchExpectation = expectation(description: "search Expectation")
        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .emptyState(let emptyStateViewModel) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertTrue(emptyStateViewModel is NoResultsEmptyState)

            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateSearchResults(with: term)

        searchService.stubSearch { _, _ in }
        searchService._results = []

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    func test_updateSearchResults_forPremiumUser_withItems_showsResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))

        let searchExpectation = expectation(description: "search Expectation")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateSearchResults(with: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    // MARK: - Offline States
    func test_updateSearchResults_forFreeUser_withOfflineArchive_showsOfflineEmptyState() async {
        networkPathMonitor.update(status: .unsatisfied)
        let user = MockUser()
        let viewModel = await subject(user: user)
        viewModel.updateScope(with: .archive, searchTerm: "search-term")

        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withOfflineArchive_showsOfflineEmptyState() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = await subject(user: MockUser(status: .premium))

        viewModel.updateScope(with: .archive)

        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)

        viewModel.updateScope(with: .archive, searchTerm: term)

        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
    }

    func test_updateSearchResults_forPremiumUser_withOfflineAll_showsOfflineEmptyState() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        networkPathMonitor.update(status: .unsatisfied)

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateScope(with: .all, searchTerm: term)
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
    }

    func test_selectingScope_whenOffline_showsOfflineEmptyState() async {
        await setupOnlineSearch(with: "search-term")

        let viewModel = await subject(user: MockUser(status: .premium))
        networkPathMonitor.update(status: .unsatisfied)

        viewModel.updateScope(with: .all, searchTerm: "search-term")
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)

        viewModel.updateScope(with: .archive, searchTerm: "search-term")
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
    }

    // MARK: - Recent Searches
    func test_recentSearches_withFreeUser_hasNoRecentSearches() async {
        source.stubSearchItems { _ in [] }

        let viewModel = await subject(user: MockUser(status: .free))
        viewModel.updateSearchResults(with: "search-term")
        guard case .recentSearches = viewModel.searchState else {
            guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
                XCTFail("Should not have failed")
                return
            }
            XCTAssertTrue(emptyStateViewModel is NoResultsEmptyState)
            return
        }
        XCTFail("Should have failed")
    }

    func test_recentSearches_withNewTerm_showsRecentSearches() async {
        searchService.stubSearch { _, _ in }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateSearchResults(with: "search-term")
        viewModel.updateScope(with: .saves)

        guard case .recentSearches(let searches) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }

        XCTAssertEqual(searches, ["search-term"])
    }

    func test_recentSearches_withDuplicateTerm_showsRecentSearches() async {
        searchService.stubSearch { _, _ in }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateSearchResults(with: "search-term")
        viewModel.updateSearchResults(with: "Search-term")
        viewModel.updateScope(with: .archive)

        guard case .recentSearches(let searches) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }

        XCTAssertEqual(searches, ["search-term"])
    }

    func test_recentSearches_withEmptyTerm_showsRecentSearchEmptyState() async {
        searchService.stubSearch { _, _ in }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateSearchResults(with: "     ")
        viewModel.updateScope(with: .all)

        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }

        XCTAssertTrue(emptyStateViewModel is RecentSearchEmptyState)
    }

    func test_recentSearches_withNewTerms_showsMaxSearches() async {
        searchService.stubSearch { _, _ in }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateSearchResults(with: "search-term-1")
        viewModel.updateSearchResults(with: "search-term-2")
        viewModel.updateSearchResults(with: "search-term-3")
        viewModel.updateSearchResults(with: "search-term-4")
        viewModel.updateSearchResults(with: "search-term-5")
        viewModel.updateSearchResults(with: "search-term-6")
        viewModel.updateScope(with: .saves)

        guard case .recentSearches(let searches) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }

        XCTAssertEqual(searches, ["search-term-2", "search-term-3", "search-term-4", "search-term-5", "search-term-6"])
    }

    func test_recentSearches_withPreviousSearch_updatesSearches() async {
        searchService.stubSearch { _, _ in }

        let viewModel = await subject(user: MockUser(status: .premium))
        viewModel.updateSearchResults(with: "search-term-1")
        viewModel.updateSearchResults(with: "search-term-2")
        viewModel.updateSearchResults(with: "search-term-3")
        viewModel.updateSearchResults(with: "search-term-4")
        viewModel.updateSearchResults(with: "search-term-5")
        viewModel.updateSearchResults(with: "search-term-6")
        viewModel.updateSearchResults(with: "search-term-2")
        viewModel.updateScope(with: .archive)

        guard case .recentSearches(let searches) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertEqual(searches, ["search-term-3", "search-term-4", "search-term-5", "search-term-6", "search-term-2"])
    }

    // MARK: - Clear
    func test_clear_resetsSearchResults() async {
        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))

        let searchResultsExpectation = expectation(description: "show search results state")
        let recentSearchesExpectation = expectation(description: "show recent searches state")

        var count = 0
        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            count += 1
            if count == 1 {
                guard case .searchResults(let results) = state else {
                    XCTFail("Should not have failed")
                    return
                }

                XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
                searchResultsExpectation.fulfill()
            } else if count == 2 {
                guard case .recentSearches(let searches) = state else {
                    XCTFail("Should not have failed")
                    return
                }

                XCTAssertEqual(searches, ["search-term"])
                recentSearchesExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        viewModel.updateSearchResults(with: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchResultsExpectation], timeout: 2.0, enforceOrder: false)

        viewModel.clear()

        await fulfillment(of: [recentSearchesExpectation], timeout: 2.0, enforceOrder: false)
    }

    func test_search_whenDeviceRegainsInternetConnection_submitsSearch() async {
        await setupOnlineSearch(with: "search-term")

        let user = MockUser()
        let viewModel = await subject(user: user)
        networkPathMonitor.update(status: .unsatisfied)
        let offlineExpectation = expectation(description: "handle offline scenario")
        let onlineExpectation = expectation(description: "handle online scenario")

        var count = 0
        viewModel.$searchState.dropFirst().receive(on: DispatchQueue.main).sink { state in
            count += 1
            if count == 1 {
                guard case .emptyState(let emptyStateViewModel) = state else {
                    XCTFail("Should not have failed")
                    return
                }

                XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
                offlineExpectation.fulfill()
            } else if count == 3 {
                guard case .searchResults(let results) = state else {
                    XCTFail("Should not have failed")
                    return
                }

                XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
                onlineExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .archive, searchTerm: "search-term")

        networkPathMonitor.update(status: .satisfied)

        await setupOnlineSearch(with: "search-term")

        await fulfillment(of: [offlineExpectation, onlineExpectation], timeout: 2, enforceOrder: true)
    }

    // MARK: - Error Handling
    func test_updateSearchResults_forPremiumUser_withOnlineSavesError_showsLocalSaves() async throws {
        let errorExpectation = expectation(description: "should throw an error")
        searchService.stubSearch { _, _ in
            errorExpectation.fulfill()
            throw TestError.anError
        }

        networkPathMonitor.update(status: .unsatisfied)
        try setupLocalSavesSearch()

        let viewModel = await subject(user: MockUser(status: .premium))
        let localSavesExpectation = expectation(description: "handle local saves scenario")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }
            XCTAssertEqual(results.compactMap { $0.title.string }, ["saved-item-1", "saved-item-2"])
            XCTAssertTrue(viewModel.showBanner)
            localSavesExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .saves, searchTerm: "saved")

        await fulfillment(of: [errorExpectation, localSavesExpectation], timeout: 2)
    }

    func test_updateSearchResults_withInternetConnectionError_showsOfflineView() async throws {
        let searchErrorExpectation = expectation(description: "should throw an error")
        searchService.stubSearch { _, _ in
            searchErrorExpectation.fulfill()
            throw SearchServiceError.noInternet
        }

        let viewModel = await subject(user: MockUser(status: .premium))
        let errorExpectation = expectation(description: "handle apollo internet connection error")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .emptyState(let emptyStateViewModel) = state else {
                XCTFail("Should not have failed")
                return
            }
            XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
            errorExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .archive, searchTerm: "search-term")

        await fulfillment(of: [searchErrorExpectation, errorExpectation], timeout: 2, enforceOrder: true)
    }

    // MARK: Load More Search Results (Pagination)
    func test_loadMoreSearchResults_forItem_showsNextPaginationResults() async {
        searchService.stubSearch { _, _ in }

        let item = space.buildSavedItem()
        let pocketItem = PocketItem(item: item)
        let term = "search-term"

        let viewModel = await subject(user: MockUser(status: .free))

        let searchExpectation = expectation(description: "search Expectation")
        viewModel.$searchState.dropFirst(3).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term", "search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .archive, searchTerm: "search-term")
        await setupOnlineSearch(with: term)

        viewModel.loadMoreSearchResults(with: pocketItem, at: 0)
        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }

    private func setupLocalSavesSearch() throws {
        let savedItems = (1...2).map {
            space.buildSavedItem(
                remoteID: "saved-item-\($0)",
                createdAt: Date(timeIntervalSince1970: TimeInterval($0)),
                item: space.buildItem(title: "saved-item-\($0)", givenURL: "item-\($0)")
            )
        }

        source.stubSearchItems { _ in return savedItems }
    }

    private func setupOnlineSearch(with term: String) async {
        searchService.stubSearch { _, _ in }
        let itemParts = SavedItemParts(
            url: "http://localhost:8080/hello",
            remoteID: "saved-item-1",
            isArchived: false,
            isFavorite: false,
            _createdAt: 1,
            item: SavedItemParts.Item.AsItem(
                remoteID: "item-1",
                givenUrl: "http://localhost:8080/hello",
                title: term
            ).asRootEntityType
        )
        let item = SearchSavedItem(remoteItem: itemParts)
        searchService._results = [item]
    }
}

// MARK: - Premium search experiment
extension DefaultSearchViewModelTests {
    func test_updateSearchResults_forPremiumUser_inExperiment_searchingByTitle_withOnlineSavesError_showsOfflineView() async throws {
        featureFlags.stubIsAssigned { _, _ in
            return true
        }

        let errorExpectation = expectation(description: "should throw an error")
        searchService.stubSearch { _, _ in
            errorExpectation.fulfill()
            throw TestError.anError
        }

        networkPathMonitor.update(status: .unsatisfied)
        await setupOnlineSearch(with: "search-term")

        let viewModel = await subject(user: MockUser(status: .premium))

        viewModel.$searchState.dropFirst().receive(on: DispatchQueue.main).sink { state in
            guard case .emptyState(let emptyStateViewModel) = state else {
                XCTFail("Should not have failed")
                return
            }
            XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
            errorExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .premiumSearchByTitle, searchTerm: "saved")

        await fulfillment(of: [errorExpectation], timeout: 2)
    }

    func test_updateSearchResults_forPremiumUser_inExperiment_searchingByTag_withOnlineSavesError_showsOfflineView() async throws {
        featureFlags.stubIsAssigned { _, _ in
            return true
        }

        let errorExpectation = expectation(description: "should throw an error")
        searchService.stubSearch { _, _ in
            errorExpectation.fulfill()
            throw TestError.anError
        }

        networkPathMonitor.update(status: .unsatisfied)
        await setupOnlineSearch(with: "search-term")

        let viewModel = await subject(user: MockUser(status: .premium))

        viewModel.$searchState.dropFirst().receive(on: DispatchQueue.main).sink { state in
            guard case .emptyState(let emptyStateViewModel) = state else {
                XCTFail("Should not have failed")
                return
            }
            XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
            errorExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .premiumSearchByTag, searchTerm: "saved")

        await fulfillment(of: [errorExpectation], timeout: 2)
    }

    func test_updateSearchResults_forPremiumUser_inExperiment_searchingByContent_withOnlineSavesError_showsOfflineView() async throws {
        let errorExpectation = expectation(description: "should throw an error")
        searchService.stubSearch { _, _ in
            errorExpectation.fulfill()
            throw TestError.anError
        }

        networkPathMonitor.update(status: .unsatisfied)
        await setupOnlineSearch(with: "search-term")

        let viewModel = await subject(user: MockUser(status: .premium))

        viewModel.$searchState.dropFirst().receive(on: DispatchQueue.main).sink { state in
            guard case .emptyState(let emptyStateViewModel) = state else {
                XCTFail("Should not have failed")
                return
            }
            XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
            errorExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .premiumSearchByContent, searchTerm: "saved")

        await fulfillment(of: [errorExpectation], timeout: 2)
    }

    func test_search_inExperiment_whenDeviceRegainsInternetConnection_submitsSearch() async {
        featureFlags.stubIsAssigned { _, _ in
            return true
        }

        await setupOnlineSearch(with: "search-term")

        let user = MockUser()
        let viewModel = await subject(user: user)
        networkPathMonitor.update(status: .unsatisfied)
        let offlineExpectation = expectation(description: "handle offline scenario")
        let onlineExpectation = expectation(description: "handle online scenario")

        var count = 0
        viewModel.$searchState.dropFirst().receive(on: DispatchQueue.main).sink { state in
            count += 1
            if count == 1 {
                guard case .emptyState(let emptyStateViewModel) = state else {
                    XCTFail("Should not have failed")
                    return
                }

                XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
                offlineExpectation.fulfill()
            } else if count == 3 {
                guard case .searchResults(let results) = state else {
                    XCTFail("Should not have failed")
                    return
                }

                XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
                onlineExpectation.fulfill()
            }
        }.store(in: &subscriptions)

        // Since the logic is the same for title, tag, and content (aside from which query filter is used),
        // we will assume that this single scope test will act the same for the others.
        viewModel.updateScope(with: .premiumSearchByTitle, searchTerm: "search-term")

        networkPathMonitor.update(status: .satisfied)

        await setupOnlineSearch(with: "search-term")

        await fulfillment(of: [offlineExpectation, onlineExpectation], timeout: 30, enforceOrder: true)
    }

    func test_selectingScope_inExperiment_whenOffline_showsOfflineEmptyState() async {
        featureFlags.stubIsAssigned { _, _ in
            return true
        }

        await setupOnlineSearch(with: "search-term")

        let viewModel = await subject(user: MockUser(status: .premium))
        networkPathMonitor.update(status: .unsatisfied)

        viewModel.updateScope(with: .all, searchTerm: "search-term")
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)

        viewModel.updateScope(with: .premiumSearchByTitle, searchTerm: "search-term")
        guard case .emptyState(let emptyStateViewModel) = viewModel.searchState else {
            XCTFail("Should not have failed")
            return
        }
        XCTAssertTrue(emptyStateViewModel is OfflineEmptyState)
    }

    // Since the logic is the same for title, tag, and content (aside from which query filter is used),
    // we will assume that this single scope test will act the same for the others.
    func test_updateScope_forPremiumUser_inExperiment_withTitleAndTerm_showsResults() async {
        featureFlags.stubIsAssigned { _, _ in
            return true
        }

        let term = "search-term"
        await setupOnlineSearch(with: term)

        let viewModel = await subject(user: MockUser(status: .premium))
        let searchExpectation = expectation(description: "search Expectation")

        viewModel.$searchState.dropFirst(2).receive(on: DispatchQueue.main).sink { state in
            guard case .searchResults(let results) = state else {
                XCTFail("Should not have failed")
                return
            }

            XCTAssertEqual(results.compactMap { $0.title.string }, ["search-term"])
            searchExpectation.fulfill()
        }.store(in: &subscriptions)

        viewModel.updateScope(with: .premiumSearchByTitle, searchTerm: term)

        await setupOnlineSearch(with: term)

        await fulfillment(of: [searchExpectation], timeout: 2)
    }
}
