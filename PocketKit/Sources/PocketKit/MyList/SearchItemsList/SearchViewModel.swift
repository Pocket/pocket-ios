import UIKit
import Network
import Sync
import Combine
import SharedPocketKit

enum SearchScope: String, CaseIterable {
    case saves = "Saves"
    case archive = "Archive"
    case all = "All Items"
}

class SearchViewModel: ObservableObject {
    static let recentSearchesKey = "Search.recentSearches"
    private var subscriptions: [AnyCancellable] = []
    private var networkPathMonitor: NetworkPathMonitor
    private var user: User
    private var userDefaults: UserDefaults
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

    init(networkPathMonitor: NetworkPathMonitor, user: User, userDefaults: UserDefaults) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
        networkPathMonitor.start(queue: DispatchQueue.global())
    }

    func updateScope(with scope: SearchScope) {
        self.selectedScope = scope
    }

    func updateSearchResults(with searchTerm: String) {
        let term = searchTerm.trimmingCharacters(in: .whitespaces).lowercased()
        let shouldShowUpsell = !isPremium && selectedScope == .all
        guard !shouldShowUpsell else { return }

        emptyState = searchResultState()
        showRecentSearches = false

        guard isPremium, !term.isEmpty else { return }
        recentSearches = updateRecentSearches(with: term)
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
