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

    private var selectedScope: SearchScope = .saves {
        didSet {
            self.emptyState = isPremium ? premiumEmptyState(for: selectedScope) : freeEmptyState(for: selectedScope)
        }
    }

    @Published
    var emptyState: EmptyStateViewModel?

    @Published
    var searchResults: [SearchItem]? {
        didSet {
            if let searchResults = searchResults {
                self.emptyState = searchResults.isEmpty ? self.searchResultState() : nil
            }
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

    init(networkPathMonitor: NetworkPathMonitor, user: User, userDefaults: UserDefaults, source: Source) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
        self.source = source
        networkPathMonitor.start(queue: DispatchQueue.global())
        self.searchService = source.makeSearchService()
    }

    func updateScope(with scope: SearchScope) {
        self.selectedScope = scope
    }

    func updateSearchResults(with searchTerm: String) {
        let term = searchTerm.trimmingCharacters(in: .whitespaces).lowercased()
        let shouldShowUpsell = !isPremium && selectedScope == .all
        guard !shouldShowUpsell else { return }
        submitSearch(with: term)
        showRecentSearches = false

        guard isPremium, !term.isEmpty else { return }
        recentSearches = updateRecentSearches(with: term)
    }

    func clear() {
        searchResults = []
        subscriptions = []
    }

    private func submitSearch(with term: String) {
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
            return isOffline ? OfflineEmptyState() : NoResultsEmptyState()
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
