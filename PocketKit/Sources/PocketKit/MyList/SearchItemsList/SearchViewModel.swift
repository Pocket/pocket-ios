// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Network
import Sync
import Combine
import SharedPocketKit
import Analytics
import CoreData

class SearchViewModel: ObservableObject {
    typealias ItemIdentifier = NSManagedObjectID
    static let recentSearchesKey = "Search.recentSearches"
    private var subscriptions: [AnyCancellable] = []
    private let networkPathMonitor: NetworkPathMonitor
    private let user: User
    private let userDefaults: UserDefaults
    private let source: Source

    private var savesLocalSearch: LocalSavesSearch
    private var savesOnlineSearch: OnlineSearch
    private var archiveOnlineSearch: OnlineSearch
    private var allOnlineSearch: OnlineSearch

    private let tracker: Tracker

    var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    private var isPremium: Bool {
        return user.status == .premium
    }

    var isPremiumAndOffline: Bool = false

    private var selectedScope: SearchScope = .saves

    @Published
    var emptyState: EmptyStateViewModel?

    @Published
    var selectedItem: SelectedItem?

    @Published
    var searchResults: [SearchItem]? {
        didSet {
            guard let searchResults = searchResults, searchResults.isEmpty else {
                return
            }
            emptyState = searchResultState()
        }
    }

    @Published
    var showRecentSearches: Bool?

    var scopeTitles: [String] {
        SearchScope.allCases.map { $0.rawValue }
    }

    var recentSearches: [String] {
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

    init(networkPathMonitor: NetworkPathMonitor, user: User, userDefaults: UserDefaults, source: Source, tracker: Tracker) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
        self.source = source
        self.tracker = tracker
        networkPathMonitor.start(queue: .global())

        savesLocalSearch = LocalSavesSearch(source: source)
        savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        allOnlineSearch = OnlineSearch(source: source, scope: .all)

        isPremiumAndOffline = isPremium && isOffline
    }

    func updateScope(with scope: SearchScope, searchTerm: String? = nil) {
        selectedScope = scope
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            updateSearchResults(with: searchTerm)
        } else {
            emptyState = isPremium ? premiumEmptyState(for: selectedScope) : freeEmptyState(for: selectedScope)
        }
    }

    func updateSearchResults(with searchTerm: String) {
        let shouldShowUpsell = !isPremium && selectedScope == .all

        guard !shouldShowUpsell else {
            clear()
            emptyState = GetPremiumEmptyState()
            return
        }

        let term = searchTerm.trimmingCharacters(in: .whitespaces).lowercased()
        guard !term.isEmpty else { return }
        guard !isOffline else {
            emptyState = searchResultState()
            return
        }
        submitSearch(with: term, scope: selectedScope)

        showRecentSearches = false
        recentSearches = updateRecentSearches(with: term)
    }

    func clear() {
        searchResults = []
        subscriptions = []
        savesLocalSearch = LocalSavesSearch(source: source)
        savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        allOnlineSearch = OnlineSearch(source: source, scope: .all)
    }

    private func submitSearch(with term: String, scope: SearchScope) {
        switch scope {
        case .saves:
            // TODO: Handle Offline for Premium https://getpocket.atlassian.net/browse/IN-971
            guard isPremium else {
                guard selectedScope == .saves else { return }
                searchResults = savesLocalSearch.search(with: term)
                return
            }
            savesOnlineSearch.search(with: term)
            savesOnlineSearch.$results.receive(on: DispatchQueue.main).sink { [weak self] items in
                guard let self, self.selectedScope == .saves else { return }
                self.searchResults = items
            }.store(in: &subscriptions)
        case .archive:
            archiveOnlineSearch.search(with: term)
            archiveOnlineSearch.$results.receive(on: DispatchQueue.main).sink { [weak self] items in
                guard let self, self.selectedScope == .archive else { return }
                self.searchResults = items
            }.store(in: &subscriptions)
        case .all:
            allOnlineSearch.search(with: term)
            allOnlineSearch.$results.receive(on: DispatchQueue.main).sink { [weak self] items in
                guard let self, self.selectedScope == .all else { return }
                self.searchResults = items
            }.store(in: &subscriptions)
        }
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
        case .saves, .archive:
            return SearchEmptyState()
        case .all:
            return GetPremiumEmptyState()
        }
    }

    private func premiumEmptyState(for scope: SearchScope) -> EmptyStateViewModel? {
        guard recentSearches.isEmpty else {
            showRecentSearches = true
            return nil
        }
        return RecentSearchEmptyState()
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
