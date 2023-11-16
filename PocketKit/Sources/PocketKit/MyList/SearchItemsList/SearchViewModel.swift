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
import Textile
import Localization

/// State for the search view
enum SearchViewState {
    case loading
    case emptyState(EmptyStateViewModel)
    case recentSearches([String])
    case searchResults([PocketItem])

    var isEmptyState: Bool {
        switch self {
        case .emptyState:
            return true
        default:
            return false
        }
    }
}

protocol SearchResultActionDelegate: AnyObject {
    func archive(item: PocketItem)
    func unarchive(item: PocketItem)
}

/// View model that holds business logic for the SearchView
class DefaultSearchViewModel: ObservableObject {
    static let recentSearchesKey = UserDefaults.Key.recentSearches

    private var subscriptions: [AnyCancellable] = []
    private let networkPathMonitor: NetworkPathMonitor
    private var lastPathStatus: NWPath.Status?
    private let user: User
    private let store: SubscriptionStore
    private let userDefaults: UserDefaults
    private var featureFlags: FeatureFlagServiceProtocol
    private let source: Source
    private let premiumUpgradeViewModelFactory: PremiumUpgradeViewModelFactory
    private let notificationCenter: NotificationCenter

    private var savesLocalSearch: LocalSavesSearch
    private var savesOnlineSearch: OnlineSearch
    private var archiveOnlineSearch: OnlineSearch
    private var allOnlineSearch: OnlineSearch
    private var premiumExperimentSearch: PremiumExperimentSearch
    // separated from the subscriptions array as that one gets cleared between searches
    private var userStatusListener: AnyCancellable?

    private let tracker: Tracker
    private let itemsController: SavedItemsController
    private var currentSearchTerm: String?

    var isOffline: Bool {
        return networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    private var isPremium: Bool {
        return user.status == .premium
    }

    private(set) var scopeTitles: [String] = SearchScope.defaultScopes.map { $0.rawValue }
    var selectedScope: SearchScope = .saves

    @Published var showBanner: Bool = false
    @Published var isPresentingPremiumUpgrade = false
    @Published var isPresentingHooray = false
    @Published var isPresentingReportIssue = false
    @Published var searchState: SearchViewState?
    @Published var selectedItem: SelectedItem?
    @Published var searchText = "" {
        didSet {
            updateSearchResults(with: searchText)
        }
    }

    /// Create the banner details to populate the view
    var bannerData: BannerModifier.BannerData {
        let offlineView = BannerModifier.BannerData(image: .looking, title: Localization.Search.limitedResults, detail: Localization.Search.offlineMessage)
        let errorView = BannerModifier.BannerData(
            image: .warning,
            title: Localization.Search.limitedResults,
            detail: Localization.Search.Banner.errorMessage,
            action: reportButton()
        )
        return isOffline ? offlineView : errorView
    }

    /// Handles whether to show a report button for a banner
    private func reportButton() -> BannerAction? {
        if featureFlags.isAssigned(flag: .reportIssue) {
            return BannerAction(
                text: Localization.General.Error.sendReport,
                style: PocketButtonStyle(.primary, .small)
            ) {
                self.isPresentingReportIssue.toggle()
            }
        }
        return nil
    }

    var defaultState: SearchViewState {
        guard let emptyStateViewModel = isPremium ? premiumEmptyState(for: selectedScope) : freeEmptyState(for: selectedScope) else {
            return .recentSearches(recentSearches)
        }
        return .emptyState(emptyStateViewModel)
    }

    private var recentSearches: [String] {
        get {
            userDefaults.stringArray(forKey: DefaultSearchViewModel.recentSearchesKey) ?? []
        }
        set {
            userDefaults.set(newValue, forKey: DefaultSearchViewModel.recentSearchesKey)
        }
    }

    init(networkPathMonitor: NetworkPathMonitor,
         user: User,
         userDefaults: UserDefaults,
         featureFlags: FeatureFlagServiceProtocol,
         source: Source,
         tracker: Tracker,
         store: SubscriptionStore,
         notificationCenter: NotificationCenter,
         premiumUpgradeViewModelFactory: @escaping PremiumUpgradeViewModelFactory) {
        self.networkPathMonitor = networkPathMonitor
        self.user = user
        self.userDefaults = userDefaults
        self.featureFlags = featureFlags
        self.source = source
        self.tracker = tracker
        self.store = store
        self.notificationCenter = notificationCenter
        self.premiumUpgradeViewModelFactory = premiumUpgradeViewModelFactory
        itemsController = source.makeSavesController()

        savesLocalSearch = LocalSavesSearch(source: source)
        savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        allOnlineSearch = OnlineSearch(source: source, scope: .all)
        premiumExperimentSearch = PremiumExperimentSearch(source: source, scope: .all)

        searchState = defaultState
        itemsController.delegate = self
        self.itemsController.predicate = Predicates.allItems()
        try? self.itemsController.performFetch()

        networkPathMonitor.start(queue: .global())
        observeNetworkChanges()
        // Listen for user status changes and update the UI accordingly.
        // Drop the first occurrence that happens when user is initialized.
        userStatusListener = user
            .statusPublisher
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard self?.searchState?.isEmptyState == true else {
                    return
                }
                self?.searchState = self?.defaultState
            }
    }

    /// Updates the scope titles based on whether the user is enrolled in the premium search scopes experiment.
    func updateScopeTitles() {
        if featureFlags.isAssigned(flag: .premiumSearchScopesExperiment, variant: nil) {
            scopeTitles = SearchScope.premiumExperimentScopes.map { $0.rawValue }
        } else {
            scopeTitles = SearchScope.defaultScopes.map { $0.rawValue }
        }
    }

    /// Updates the scope user is in and presents an empty state or submits a search
    /// - Parameters:
    ///   - scope: the scope that the user is in (i.e. saves, archive, all)
    ///   - searchTerm: the term the user enters in search bar
    func updateScope(with scope: SearchScope, searchTerm: String? = nil) {
        selectedScope = scope
        if let searchTerm = searchTerm, !searchTerm.isEmpty {
            updateSearchResults(with: searchTerm)
        } else {
            searchState = defaultState
        }
    }

    /// Handles logic for when a user enters a search, such as showing Get Premium for user in All Items, checking if user is Offline or submitting a search
    /// - Parameter searchTerm: the term the user enters in search bar
    func updateSearchResults(with searchTerm: String) {
        let shouldShowUpsell = !isPremium && selectedScope == .all

        guard !shouldShowUpsell else {
            searchState = .emptyState(GetPremiumEmptyState())
            return
        }

        resetSearch(with: searchTerm)

        let term = searchTerm.trimmingCharacters(in: .whitespaces).lowercased()
        currentSearchTerm = term
        guard !isOffline || selectedScope == .saves else {
            searchState = .emptyState(searchResultState())
            return
        }
        guard !term.isEmpty else {
            searchState = .emptyState(searchResultState())
            return
        }
        trackPerformSearch()
        searchState = .loading
        submitSearch(with: term, scope: selectedScope)
        recentSearches = updateRecentSearches(with: term)
    }

    /// Resets the search objects and clears state
    func clear() {
        searchState = defaultState
        currentSearchTerm = nil

        showBanner = false
        subscriptions = []

        savesLocalSearch = LocalSavesSearch(source: source)
        savesOnlineSearch = OnlineSearch(source: source, scope: .saves)
        archiveOnlineSearch = OnlineSearch(source: source, scope: .archive)
        allOnlineSearch = OnlineSearch(source: source, scope: .all)
        premiumExperimentSearch = PremiumExperimentSearch(source: source, scope: .all)
    }

    /// Resets the search objects if it does not have a cache before each search
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

        if !premiumExperimentSearch.hasCache(with: term) {
            premiumExperimentSearch = PremiumExperimentSearch(source: source, scope: .all)
        }
    }

    /// Used to load more results if a users scrolls down the list
    /// - Parameter item: last item in the list to be used to fetch the next page
    func loadMoreSearchResults(with item: PocketItem, at index: Int) {
        guard let term = currentSearchTerm else {
            Log.debug("Search should have a current term before submitting search")
            return
        }
        switch selectedScope {
        case .saves:
            guard isPremium, !savesOnlineSearch.hasFinishedResults else { return }
            savesOnlineSearch.search(with: term, and: true)
        case .archive:
            guard !archiveOnlineSearch.hasFinishedResults else { return }
            archiveOnlineSearch.search(with: term, and: true)
        case .all:
            guard !allOnlineSearch.hasFinishedResults else { return }
            allOnlineSearch.search(with: term, and: true)
        case .premiumExperimentTitle, .premiumExperimentTags, .premiumExperimentContent:
            guard !premiumExperimentSearch.hasFinishedResults else { return }
            premiumExperimentSearch.search(with: term, shouldLoadMoreResults: true)
            return // TODO: Update for premium search experiment
        }
    }

    func beginBulkEdit() {
        // TODO: The context of a bulk edit is within the entire list, not a single search result.
        // Maybe there's potential for this being lifted from the row _to_ the search results list.
        let bannerData = BannerModifier.BannerData(
            image: .warning,
            title: "",
            detail: "Editing your search results is not available in this version of Pocket, but will be returning soon!"
        )

        notificationCenter.post(name: .bannerRequested, object: bannerData)
    }

    /// Handles submitting a search for the different scopes
    /// - Parameters:
    ///   - term: the term the user enters in search bar
    ///   - scope: the scope that the user is in (i.e. saves, archive, all)
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
        case .premiumExperimentTitle, .premiumExperimentTags, .premiumExperimentContent:
            premiumExperimentSearch.search(with: term)
            listenForResults(with: term, premiumExperimentSearch: premiumExperimentSearch, scope: .all)
        }
    }

    /// Submit search for saves (local for free user, online for premium user unless offline)
    /// - Parameter term: the term the user enters in search bar
    private func searchSaves(with term: String) {
        guard isPremium else {
            guard selectedScope == .saves else { return }
            let results = savesLocalSearch.search(with: term)
            searchState = results.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(results)
            return
        }
        savesOnlineSearch.search(with: term)
    }

    /// Submit online search for saves and update `searchState` with proper view
    /// - Parameter term: the term the user enters in search bar
    private func listenForSaveResults(with term: String) {
        savesOnlineSearch.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result, self.selectedScope == .saves else { return }
                if case .success(let items) = result {
                    self.searchState = items.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(items)
                    self.trackSearchResultsPage(pageNumber: self.savesOnlineSearch.pageNumberLoaded, scope: .saves)
                } else {
                    let results = self.savesLocalSearch.search(with: term)
                    self.searchState = .searchResults(results)
                    self.showBanner = self.isPremium
                }
            }
            .store(in: &subscriptions)
    }

    /// Submit online search and update `searchState` with proper view
    /// - Parameter term: the term the user enters in search bar

    /// Submit online search and update `searchState` with proper view
    /// - Parameters:
    ///   - term: the term the user enters in search bar
    ///   - onlineSearch: object for online search (archive, all)
    ///   - scope: the scope that the user is in (i.e. saves, archive, all)
    private func listenForResults(with term: String, onlineSearch: OnlineSearch, scope: SearchScope) {
        onlineSearch.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result, self.selectedScope == scope else { return }
                if case .success(let items) = result {
                    self.searchState = items.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(items)
                    self.trackSearchResultsPage(pageNumber: onlineSearch.pageNumberLoaded, scope: scope)
                } else if case .failure(let error) = result {
                    guard case SearchServiceError.noInternet = error else {
                        self.searchState = .emptyState(ErrorEmptyState(featureFlags: featureFlags, user: user))
                        return
                    }
                    self.searchState = .emptyState(OfflineEmptyState(type: scope))
                }
            }
            .store(in: &subscriptions)
    }

    /// Submit premium experiment search and update `searchState` with proper view
    /// - Parameter term: the term the user enters in search bar

    /// Submit premium experiment search and update `searchState` with proper view
    /// - Parameters:
    ///   - term: the term the user enters in search bar
    ///   - premiumExperimentSearch: object for premium experiment search
    ///   - scope: the scope that the user is in (i.e. title, tags, content)
    private func listenForResults(with term: String, premiumExperimentSearch: PremiumExperimentSearch, scope: SearchScope) {
        premiumExperimentSearch.$results
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self, let result, self.selectedScope == scope else { return }
                if case .success(let items) = result {
                    self.searchState = items.isEmpty ? .emptyState(self.searchResultState()) : .searchResults(items)
                    self.trackSearchResultsPage(pageNumber: premiumExperimentSearch.pageNumberLoaded, scope: scope)
                } else if case .failure(let error) = result {
                    guard case SearchServiceError.noInternet = error else {
                        self.searchState = .emptyState(ErrorEmptyState(featureFlags: featureFlags, user: user))
                        return
                    }
                    self.searchState = .emptyState(OfflineEmptyState(type: scope))
                }
            }
            .store(in: &subscriptions)
    }

    /// Updates recent searches after user submits a search up to 5 terms
    /// - Parameter searchTerm: the term the user enters in search bar
    /// - Returns: array of strings with the recent search terms
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

    /// Retrieves empty state after submitting a search
    /// - Returns: view model for the empty state
    private func searchResultState() -> EmptyStateViewModel {
        switch selectedScope {
        case .saves:
            return NoResultsEmptyState()
        case .archive, .all:
            return isOffline ? OfflineEmptyState(type: selectedScope) : NoResultsEmptyState()
        case .premiumExperimentTitle, .premiumExperimentTags, .premiumExperimentContent:
            return isOffline ? OfflineEmptyState(type: selectedScope) : NoResultsEmptyState() // TODO: Update for premium search experiment
        }
    }

    /// Retrieves empty state when a free user enters search
    /// - Parameter scope: the scope that the user is in (i.e. saves, archive, all)
    /// - Returns: view model for the empty state
    private func freeEmptyState(for scope: SearchScope) -> EmptyStateViewModel {
        switch scope {
        case .saves:
            return SearchEmptyState()
        case .archive:
            return isOffline ? OfflineEmptyState(type: .archive) : SearchEmptyState()
        case .all:
            return GetPremiumEmptyState()
        case .premiumExperimentTitle, .premiumExperimentTags, .premiumExperimentContent:
            return isOffline ? OfflineEmptyState(type: .archive) : SearchEmptyState() // TODO: Update for premium search experiment
        }
    }

    /// Retrieves empty state when a premium user enters search
    /// - Parameter scope: the scope that the user is in (i.e. saves, archive, all)
    /// - Returns: view model for the empty state
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

    /// Observes network changes and resubmit search when user returns online
    private func handleNetworkChange(_ path: NetworkPath?) {
        let currentPathStatus = path?.status

        if lastPathStatus == .unsatisfied, currentPathStatus == .satisfied {
            guard let currentSearchTerm, !currentSearchTerm.isEmpty, selectedScope == .archive || selectedScope == .all else { return }
            updateSearchResults(with: currentSearchTerm)
        }

        lastPathStatus = currentPathStatus
    }
}

extension DefaultSearchViewModel: SearchResultActionDelegate {
    func itemViewModel(_ searchItem: PocketItem, index: Int) -> PocketItemViewModel {
        return PocketItemViewModel(
            item: searchItem,
            index: index,
            source: source,
            tracker: tracker,
            userDefaults: userDefaults,
            scope: selectedScope,
            user: user,
            store: store,
            networkPathMonitor: networkPathMonitor,
            searchActionDelegate: self
        )
    }

    func select(_ searchItem: PocketItem, index: Int) {
        guard
            let savedItem = source.fetchOrCreateSavedItem(
                with: searchItem.savedItemURL,
                and: searchItem.remoteItemParts
            )
        else {
            Log.capture(message: "Saved Item not created")
            return
        }

        let readable = SavedItemViewModel(
            item: savedItem,
            source: source,
            tracker: tracker.childTracker(hosting: .articleView.screen),
            pasteboard: UIPasteboard.general,
            user: user,
            store: store,
            networkPathMonitor: networkPathMonitor,
            userDefaults: userDefaults,
            notificationCenter: notificationCenter,
            featureFlagService: featureFlags
        )

        if let slug = readable.slug, featureFlags.isAssigned(flag: .nativeCollections) {
            let collectionViewModel = CollectionViewModel(slug: slug, source: source, tracker: tracker, user: user, store: store, networkPathMonitor: networkPathMonitor, userDefaults: userDefaults, featureFlags: featureFlags, notificationCenter: notificationCenter)
            selectedItem = .collection(collectionViewModel)
        } else if savedItem.shouldOpenInWebView(override: featureFlags.shouldDisableReader) {
            trackOpenSearchItem(url: savedItem.url, index: index, destination: .internal)
            selectedItem = .webView(readable)
        } else {
            trackOpenSearchItem(url: savedItem.url, index: index, destination: .external)
            selectedItem = .readable(readable)
        }
    }

    func swipeActionTitle(_ searchItem: PocketItem) -> String {
        if searchItem.isArchived {
            return Localization.Search.Swipe.moveToSaves
        } else {
            return Localization.Search.Swipe.archive
        }
    }

    func handleSwipeAction(_ searchItem: PocketItem, index: Int) {
        guard let savedItem = fetchSavedItem(searchItem) else { return }
        if savedItem.isArchived {
            moveToSaves(savedItem, index: index)
        } else {
            archive(savedItem, index: index)
        }
    }

    func archive(item: PocketItem) {
        guard let savedItem = fetchSavedItem(item) else { return }
        updateLocalSearchResults(ByRemoving: savedItem)
    }

    func unarchive(item: PocketItem) {
        guard let savedItem = fetchSavedItem(item) else { return }
        updateLocalSearchResults(ByRemoving: savedItem)
    }

    /// Triggers action to archive an item in a list
    func archive(_ savedItem: SavedItem, index: Int) {
        tracker.track(event: Events.Search.archiveItem(itemUrl: savedItem.url, positionInList: index, scope: selectedScope))
        source.archive(item: savedItem)
        updateLocalSearchResults(ByRemoving: savedItem)
    }

    /// Triggers action to move an item from archive to saves in a list
    func moveToSaves(_ savedItem: SavedItem, index: Int) {
        tracker.track(event: Events.Search.unarchiveItem(itemUrl: savedItem.url, positionInList: index, scope: selectedScope))
        source.unarchive(item: savedItem)
        updateLocalSearchResults(ByRemoving: savedItem)
    }

    private func updateLocalSearchResults(ByRemoving item: SavedItem) {
        guard selectedScope != .all else { return }

        if case let .searchResults(results) = searchState {
            let updatedResults = results.filter {
                $0.id != item.id
            }

            if updatedResults.isEmpty {
                searchState = defaultState
            } else {
                searchState = .searchResults(updatedResults)
            }
        }
    }

    func fetchSavedItem(_ searchItem: PocketItem) -> SavedItem? {
        guard let savedItem = source.fetchOrCreateSavedItem(
            with: searchItem.savedItemURL,
            and: searchItem.remoteItemParts
        ) else {
            Log.capture(message: "Saved Item not created")
            return nil
        }
        return savedItem
    }
}

// MARK: Analytics
extension DefaultSearchViewModel {
    /// Tracks when user opens search (magnifying glass or pull down)
    func trackOpenSearch() {
        tracker.track(event: Events.Search.openSearch(scope: selectedScope))
    }

    /// Tracks when user submits a search
    func trackPerformSearch() {
        tracker.track(event: Events.Search.submitSearch(scope: selectedScope))
    }

    /// Tracks when user switches search scope
    /// - Parameter scope: scope that user switched to (saves, archive, all)
    func trackSwitchScope(with scope: SearchScope) {
        tracker.track(event: Events.Search.switchScope(scope: scope))
    }

    /// Track item that user views on the search results page
    /// - Parameters:
    ///   - url: url associated with the item
    ///   - index: position index of item in the list
    func trackViewResults(url: String, index: Int) {
        tracker.track(event: Events.Search.searchCardImpression(url: url, positionInList: index, scope: selectedScope))
    }

    /// Track when user opens a search item
    /// - Parameters:
    ///   - url: url associated with the item
    ///   - index: position index of item in the list
    func trackOpenSearchItem(url: String, index: Int, destination: ContentOpen.Destination) {
        tracker.track(event: Events.Search.searchCardContentOpen(url: url, positionInList: index, scope: selectedScope, destination: destination))
    }

    /// Track when user triggers a search page call
    /// - Parameters:
    ///   - pageNumber: page number of search results that was loaded
    ///   - scope: scope that the page was loaded in
    func trackSearchResultsPage(pageNumber: Int, scope: SearchScope) {
        tracker.track(event: Events.Search.searchResultsPage(pageNumber: pageNumber, scope: scope))
    }

    /// track premium upgrade view dismissed
    func trackPremiumDismissed(dismissReason: DismissReason) {
        switch dismissReason {
        case .swipe, .button, .closeButton:
            tracker.track(event: Events.Premium.premiumUpgradeViewDismissed(reason: dismissReason))
        case .system:
            break
        }
    }
    /// track premium upsell viewed
    func trackPremiumUpsellViewed() {
        tracker.track(event: Events.Search.premiumUpsellViewed())
    }
}

extension DefaultSearchViewModel: SavedItemsControllerDelegate {
    func controller(
        _ controller: SavedItemsController,
        didChange savedItem: SavedItem,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        // no-op
    }

    func controller(_ controller: SavedItemsController, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        guard case .searchResults(let items) = searchState, let savedItems = items.map({ $0.item }) as? [SavedItem] else {
            return
        }
        let currentObjectIDs = savedItems.map { $0.objectID }
        let snapshotIDs = snapshot.itemIdentifiers as! [NSManagedObjectID]
        let deletedIDs = currentObjectIDs.filter { snapshotIDs.contains($0) == false }
        let updatedItems = savedItems
            .filter { deletedIDs.contains($0.objectID) == false }
            .filter { outOfScope($0) }
            .map { PocketItem(item: $0) }
        searchState = .searchResults(updatedItems)
    }

    /// Checks if a saved item should be moved to archive or vice versa
    private func outOfScope(_ savedItem: SavedItem) -> Bool {
        (savedItem.isArchived && selectedScope == .saves) || (!savedItem.isArchived && selectedScope == .archive)
    }
}

// MARK: Premium upgrades
extension DefaultSearchViewModel {
    @MainActor
    func makePremiumUpgradeViewModel() -> PremiumUpgradeViewModel {
        premiumUpgradeViewModelFactory(.search)
    }

    /// Ttoggle the presentation of `PremiumUpgradeView`
    func showPremiumUpgrade() {
        self.isPresentingPremiumUpgrade = true
    }
}

// MARK: Sentry User Feedback Reporting
extension DefaultSearchViewModel {
    var userEmail: String {
        user.email
    }

    func submitIssue(name: String, email: String, comments: String) {
        Log.captureUserFeedback(message: "Report an issue", name: name, email: email, comments: comments)
    }
}
