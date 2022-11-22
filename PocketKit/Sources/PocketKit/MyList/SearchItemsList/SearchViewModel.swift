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

    private var subscriptions: [AnyCancellable] = []
    private var networkPathMonitor: NetworkPathMonitor
    private var user: User
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

    var scopeTitles: [String] {
        SearchScope.allCases.map { $0.rawValue }
    }

    init(networkPathMonitor: NetworkPathMonitor, user: User) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        networkPathMonitor.start(queue: DispatchQueue.global())
    }

    @Published
    var emptyState: EmptyStateViewModel?

    func updateSearchResults(with searchTerm: String) {
        let shouldShowUpsell = !isPremium && selectedScope == .all
        guard !shouldShowUpsell else { return }
        emptyState = NoResultsEmptyState()
    }

    func updateScope(with scope: SearchScope) {
        self.selectedScope = scope
    }

    private func freeEmptyState(for scope: SearchScope) -> EmptyStateViewModel {
        switch scope {
        case .saves:
            return SearchEmptyState()
        case .archive:
            return isOffline ? OfflineEmptyState() : SearchEmptyState()
        case .all:
            return GetPremiumEmptyState()
        }
    }

    private func premiumEmptyState(for scope: SearchScope) -> EmptyStateViewModel {
        switch scope {
        case .saves:
            return RecentSearchEmptyState()
        case .archive, .all:
            return isOffline ? OfflineEmptyState() : RecentSearchEmptyState()
        }
    }
}
