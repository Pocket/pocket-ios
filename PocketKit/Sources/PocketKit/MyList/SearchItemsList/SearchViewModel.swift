// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Network
import Sync
import Combine
import SharedPocketKit
import Analytics

enum SearchViewState {
    case loading
    case emptyState(EmptyStateViewModel)
    case recentSearches([String])
    case searchResults([SearchItem])

    var isEmptyState: Bool {
        switch self {
        case .emptyState:
            return true
        default:
            return false
        }
    }
}

class SearchViewModel: ObservableObject {
    static let recentSearchesKey = "Search.recentSearches"
    private var subscriptions: [AnyCancellable] = []
    private let networkPathMonitor: NetworkPathMonitor
    private var lastPathStatus: NWPath.Status?
    private let user: User
    private let userDefaults: UserDefaults
    private let source: Source
    private let premiumUpgradeViewModelFactory: () -> PremiumUpgradeViewModel

    private var savesLocalSearch: LocalSavesSearch
    private var savesOnlineSearch: OnlineSearch
    private var archiveOnlineSearch: OnlineSearch
    private var allOnlineSearch: OnlineSearch
    // separated from the subscriptions array as that one gets cleared between searches
    private var userStatusListener: AnyCancellable?

    private let tracker: Tracker

    private var currentSearchTerm: String?

    var isOffline: Bool {
        return networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    private var isPremium: Bool {
        return user.status == .premium
    }

    private var selectedScope: SearchScope = .saves

    @Published var showBanner: Bool = false
    @Published var isPresentingPremiumUpgrade = false

    var bannerData: BannerModifier.BannerData {
        let offlineView = BannerModifier.BannerData(image: .looking, title: L10n.Search.limitedResults, detail: L10n.Search.offlineMessage)
        let errorView = BannerModifier.BannerData(image: .warning, title: L10n.Search.limitedResults, detail: L10n.Search.Banner.errorMessage)
        return isOffline ? offlineView : errorView
    }

    @Published
    var searchState: SearchViewState?

    var defaultState: SearchViewState {
        guard let emptyStateViewModel = isPremium ? premiumEmptyState(for: selectedScope) : freeEmptyState(for: selectedScope) else {
            return .recentSearches(recentSearches)
        }
        return .emptyState(emptyStateViewModel)
    }

    @Published
    var selectedItem: SelectedItem?

    var scopeTitles: [String] {
        SearchScope.allCases.map { $0.rawValue }
    }

    private var recentSearches: [String] {
        get {
            userDefaults.stringArray(forKey: SearchViewModel.recentSearchesKey) ?? []
        }
        set {
            userDefaults.set(newValue, forKey: SearchViewModel.recentSearchesKey)
        }
    }

    @Published var searchText = "" {
        didSet {
            updateSearchResults(with: searchText)
        }
    }

    init(networkPathMonitor: NetworkPathMonitor,
         user: User,
         userDefaults: UserDefaults,
         source: Source,
         tracker: Tracker,
         premiumUpgradeViewModelFactory: @escaping () -> PremiumUpgradeViewModel) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
        self.source = source
        self.tracker = tracker
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory

        savesLocalSearch = LocalSavesSearch(source: source)
        savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        allOnlineSearch = OnlineSearch(source: source, scope: .all)

        searchState = defaultState

        networkPathMonitor.start(queue: .global())
        observeNetworkChanges()

        userStatusListener = user
            .statusPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard self?.searchState?.isEmptyState == true else {
                    return
                }
                self?.searchState = self?.defaultState
            }
    }

    func updateScope(with scope: SearchScope, searchTerm: String? = nil) {
        selectedScope = scope
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            updateSearchResults(with: searchTerm)
        } else {
            searchState = defaultState
        }
    }

    func updateSearchResults(with searchTerm: String) {
        let shouldShowUpsell = !isPremium && selectedScope == .all

        guard !shouldShowUpsell else {
            searchState = .emptyState(GetPremiumEmptyState())
            return
        }

        resetSearch(with: searchTerm)

        let term = searchTerm.trimmingCharacters(in: .whitespaces).lowercased()
        currentSearchTerm = term
        guard !term.isEmpty else { return }
        guard !isOffline || selectedScope == .saves else {
            searchState = .emptyState(searchResultState())
            return
        }
        searchState = .loading
        submitSearch(with: term, scope: selectedScope)
        recentSearches = updateRecentSearches(with: term)
    }

    func clear() {
        searchState = defaultState
        currentSearchTerm = nil

        showBanner = false
        subscriptions = []

        savesLocalSearch = LocalSavesSearch(source: source)
        savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        allOnlineSearch = OnlineSearch(source: source, scope: .all)
    }

    private func resetSearch(with term: String) {
        showBanner = false
        subscriptions = []

        if !savesOnlineSearch.hasCache(with: term) {
            savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        }

        if !archiveOnlineSearch.hasCache(with: term) {
            archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        }

        if !allOnlineSearch.hasCache(with: term) {
            allOnlineSearch = OnlineSearch(source: source, scope: .all)
        }
    }

    private func submitSearch(with term: String, scope: SearchScope) {
        switch scope {
        case .saves:
            searchSaves(with: term)
            listenForSaveResults(with: term)
        case .archive:
            archiveOnlineSearch.search(with: term)
            listenForResults(with: term, onlineSearch: archiveOnlineSearch, scope: .archive)
        case .all:
            allOnlineSearch.search(with: term)
            listenForResults(with: term, onlineSearch: allOnlineSearch, scope: .all)
        }
    }

    private func searchSaves(with term: String) {
        guard isPremium else {
            guard selectedScope == .saves else { return }
            let results = savesLocalSearch.search(with: term)
            searchState = results.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(results)
            return
        }
        savesOnlineSearch.search(with: term)
    }

    private func listenForSaveResults(with term: String) {
        savesOnlineSearch.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result, self.selectedScope == .saves else { return }
                if case .success(let items) = result {
                    self.searchState = items.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(items)
                } else {
                    let results = self.savesLocalSearch.search(with: term)
                    self.searchState = .searchResults(results)
                    self.showBanner = self.isPremium
                }
            }
            .store(in: &subscriptions)
    }

    private func listenForResults(with term: String, onlineSearch: OnlineSearch, scope: SearchScope) {
        onlineSearch.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result, self.selectedScope == scope else { return }
                if case .success(let items) = result {
                    self.searchState = items.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(items)
                } else if case .failure(let error) = result {
                    guard case SearchServiceError.noInternet = error else {
                        self.searchState = .emptyState(ErrorEmptyState())
                        return
                    }
                    self.searchState = .emptyState(OfflineEmptyState(type: scope))
                }
            }
            .store(in: &subscriptions)
    }

    private func updateRecentSearches(with searchTerm: String) -> [String] {
        guard isPremium else { return [] }
        var searches = recentSearches
        searches.append(searchTerm)

        if let index = recentSearches.firstIndex(of: searchTerm) {
            searches.remove(at: index)
        }

        guard searches.count > 5 else { return searches }

        searches.removeFirst()
        return searches
    }

    private func searchResultState() -> EmptyStateViewModel {
        // TODO: Add loading state
        switch selectedScope {
        case .saves:
            return NoResultsEmptyState()
        case .archive, .all:
            return isOffline ? OfflineEmptyState(type: selectedScope) : NoResultsEmptyState()
        }
    }

    private func freeEmptyState(for scope: SearchScope) -> EmptyStateViewModel {
        switch scope {
        case .saves:
            return SearchEmptyState()
        case .archive:
            return isOffline ? OfflineEmptyState(type: .archive) : SearchEmptyState()
        case .all:
            return GetPremiumEmptyState()
        }
    }

    private func premiumEmptyState(for scope: SearchScope) -> EmptyStateViewModel? {
        guard !isOffline || selectedScope == .saves else {
            return OfflineEmptyState(type: scope)
        }
        guard recentSearches.isEmpty else { return nil }
        return RecentSearchEmptyState()
    }

    private func observeNetworkChanges() {
        networkPathMonitor.updateHandler = { [weak self] path in
            self?.handleNetworkChange(path)
        }
    }

    private func handleNetworkChange(_ path: NetworkPath?) {
        let currentPathStatus = path?.status

        if lastPathStatus == .unsatisfied, currentPathStatus == .satisfied {
            guard let currentSearchTerm, !currentSearchTerm.isEmpty, selectedScope == .archive || selectedScope == .all else { return }
            updateSearchResults(with: currentSearchTerm)
        }

        lastPathStatus = currentPathStatus
    }
}

extension SearchViewModel {
    func select(_ searchItem: SearchItem) {
        guard
            let id = searchItem.id,
            let savedItem = source.fetchOrCreateSavedItem(
                with: id,
                and: searchItem.remoteItemParts
            )
        else {
            return
        }

        let readable = SavedItemViewModel(
            item: savedItem,
            source: source,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            pasteboard: UIPasteboard.general
        )

        if savedItem.shouldOpenInWebView {
            selectedItem = .webView(readable)

            trackContentOpen(destination: .external, item: savedItem)
        } else {
            selectedItem = .readable(readable)

            trackContentOpen(destination: .internal, item: savedItem)
        }
    }

    private func trackContentOpen(destination: ContentOpenEvent.Destination, item: SavedItem) {
        guard let url = item.bestURL else {
            return
        }

        let contexts: [Context] = [
            ContentContext(url: url)
        ]

        let event = ContentOpenEvent(destination: destination, trigger: .click)
        tracker.track(event: event, contexts)
    }
}

// MARK: Premium upgrades
extension SearchViewModel {
    @MainActor
    func makePremiumUpgradeViewModel() -> PremiumUpgradeViewModel {
        premiumUpgradeViewModelFactory()
    }

    /// Ttoggle the presentation of `PremiumUpgradeView`
    func showPremiumUpgrade() {
        self.isPresentingPremiumUpgrade = true
    }
}
