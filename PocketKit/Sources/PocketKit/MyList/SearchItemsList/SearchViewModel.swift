import UIKit
import Network
import Sync
import Combine
import SharedPocketKit

class SearchViewModel: ObservableObject {
    static let recentSearchesKey = "Search.recentSearches"
    private var subscriptions: [AnyCancellable] = []
    private let networkPathMonitor: NetworkPathMonitor
    private let user: User
    private let userDefaults: UserDefaults
    private let source: Source
    private let searchService: SearchService
    private var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    private var isPremium: Bool {
        return user.status == .premium
    }

    private var selectedScope: SearchScope = .saves
    private var currentSearchTerm: String = ""

    private var cachedSearchResults: [SearchScope: [String: [SearchItem]]] = [
        .saves: [:],
        .archive: [:],
        .all: [:]
    ]

    @Published
    var emptyState: EmptyStateViewModel?

    @Published
    var searchResults: [SearchItem]? {
        didSet {
            guard let searchResults = searchResults, !searchResults.isEmpty, !currentSearchTerm.isEmpty else {
                self.emptyState = self.searchResultState()
                return
            }
            self.cachedSearchResults[selectedScope]?[currentSearchTerm] = searchResults
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

    init(networkPathMonitor: NetworkPathMonitor, user: User, userDefaults: UserDefaults, source: Source) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
        self.source = source
        networkPathMonitor.start(queue: .global())
        self.searchService = source.makeSearchService()
    }

    func updateScope(with scope: SearchScope, searchTerm: String? = nil) {
        self.selectedScope = scope
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
        currentSearchTerm = term
        guard !term.isEmpty, !retrieveCachedResults() else { return }

        // TODO: Handle Offline for Premium https://getpocket.atlassian.net/browse/IN-971
        if !isPremium && selectedScope == .saves {
            submitLocalSearch(with: term)
        } else {
            submitOnlineSearch(with: term)
        }

        showRecentSearches = false
        recentSearches = updateRecentSearches(with: term)
    }

    func clear() {
        searchResults = []
        subscriptions = []
    }

    func clearCache() {
        cachedSearchResults = [
            .saves: [:],
            .archive: [:],
            .all: [:]
        ]
    }

    private func retrieveCachedResults() -> Bool {
        if let cachedItems = cachedSearchResults[selectedScope]?[currentSearchTerm], !cachedItems.isEmpty {
            self.searchResults = cachedItems
            return true
        }
        return false
    }

    private func submitOnlineSearch(with term: String) {
        clear()
        searchService.results.receive(on: DispatchQueue.main).sink { [weak self] items in
            guard let self else { return }
            self.searchResults = items.compactMap { SearchItem(item: $0) }
        }.store(in: &subscriptions)
        Task {
            await searchService.search(for: term, scope: selectedScope)
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

    public func submitLocalSearch(with term: String) {
        let list = source.searchSaves(search: term)
        self.searchResults = list?.compactMap { SearchItem(item: $0) } ?? []
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
