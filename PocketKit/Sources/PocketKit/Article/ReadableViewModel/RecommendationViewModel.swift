import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics

class RecommendationViewModel: ReadableViewModel {
    @Published
    private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher { _events.eraseToAnyPublisher() }

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var isPresentingReaderSettings: Bool?

    @Published
    var selectedRecommendationToReport: Recommendation?

    private let recommendation: Recommendation
    private let source: Source
    private let pasteboard: Pasteboard
    let tracker: Tracker

    private var savedItemCancellable: AnyCancellable?
    private var savedItemSubscriptions: Set<AnyCancellable> = []

    init(recommendation: Recommendation, source: Source, tracker: Tracker, pasteboard: Pasteboard) {
        self.recommendation = recommendation
        self.source = source
        self.tracker = tracker
        self.pasteboard = pasteboard

        self.savedItemCancellable = recommendation.item?.publisher(for: \.savedItem).sink { [weak self] savedItem in
            self?.update(for: savedItem)
        }
    }

    var components: [ArticleComponent]? {
        recommendation.item?.article?.components
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings()
    }

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: recommendation.item?.language)
    }

    var title: String? {
        recommendation.item?.title
    }

    var authors: [ReadableAuthor]? {
        recommendation.item?.authors?.compactMap { $0 as? Author }
    }

    var domain: String? {
        recommendation.item?.domainMetadata?.name ?? recommendation.item?.domain ?? recommendation.item?.bestURL?.host
    }

    var publishDate: Date? {
        recommendation.item?.datePublished
    }

    var url: URL? {
        recommendation.item?.bestURL
    }

    func moveToSaves() {
        guard let savedItem = recommendation.item?.savedItem else {
            return
        }

        source.unarchive(item: savedItem)
    }

    func delete() {
        guard let savedItem = recommendation.item?.savedItem else {
            return
        }

        source.delete(item: savedItem)
        _events.send(.delete)
    }

    func archiveArticle() {
        archive()
    }

    func fetchDetailsIfNeeded() {
        guard recommendation.item?.article == nil else {
            _events.send(.contentUpdated)
            return
        }

        Task {
            try await source.fetchDetails(for: recommendation)
            _events.send(.contentUpdated)
        }
    }

    func externalActions(for url: URL) -> [ItemAction] {
        [
            .save { [weak self] _ in self?.saveExternalURL(url) },
            .open { [weak self] _ in self?.openExternalURL(url) },
            .copyLink { [weak self] _ in self?.copyExternalURL(url) },
            .share { [weak self] _ in self?.shareExternalURL(url) }
        ]
    }

    func webViewActivityItems(url: URL) -> [UIActivity] {
        guard let item = source.fetchItem(url) else {
            return []
        }

        if !item.isSaved {
            // When recommendation is Not saved
            let saveActivity = ReaderActionsWebActivity(title: .save) { [weak self] in
                if item.isSaved {
                    self?.archive()
                } else {
                    self?.save()
                }
            }

            let reportActivity = ReaderActionsWebActivity(title: .report) { [weak self] in
                self?.report()
            }
            return [saveActivity, reportActivity]
        } else {
            // When recommendation is saved
            guard let savedItem = item.savedItem else {
                return []
            }
            return webViewActivityItems(for: savedItem)
        }
    }
}

extension RecommendationViewModel {
    private func buildActions() {
        guard let savedItem = recommendation.item?.savedItem else {
            _actions = [
                .displaySettings { [weak self] _ in self?.displaySettings() },
                .save { [weak self] _ in self?.save() },
                .share { [weak self] _ in self?.share() },
                .report { [weak self] _ in self?.report() }
            ]

            return
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in self?.unfavorite() }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite() }
        }

        let archiveAction: ItemAction
        if savedItem.isArchived {
            archiveAction = .moveToSaves { [weak self] _ in self?.moveToSaves() }
        } else {
            archiveAction = .archive { [weak self] _ in self?.archive() }
        }

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() },
            favoriteAction,
            archiveAction,
            .delete { [weak self] _ in self?.confirmDelete() },
            .share { [weak self] _ in self?.share() }
        ]
    }

    private func subscribe(to savedItem: SavedItem?) {
        savedItem?.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &savedItemSubscriptions)

        savedItem?.publisher(for: \.isArchived).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &savedItemSubscriptions)
    }

    private func update(for savedItem: SavedItem?) {
        if savedItem == nil {
            savedItemSubscriptions = []
        }

        buildActions()
        subscribe(to: savedItem)
    }

    private func report() {
        selectedRecommendationToReport = recommendation
    }

    func favorite() {
        guard let savedItem = recommendation.item?.savedItem else {
            return
        }

        source.favorite(item: savedItem)
        track(identifier: .itemFavorite)
    }

    func unfavorite() {
        guard let savedItem = recommendation.item?.savedItem else {
            return
        }

        source.unfavorite(item: savedItem)
        track(identifier: .itemUnfavorite)
    }

    private func archive() {
        guard let savedItem = recommendation.item?.savedItem else {
            return
        }

        source.archive(item: savedItem)
        track(identifier: .itemArchive)
        _events.send(.archive)
    }

    private func save() {
        source.save(recommendation: recommendation)
        track(identifier: .itemSave)
    }

    private func saveExternalURL(_ url: URL) {
        source.save(url: url)
    }

    private func copyExternalURL(_ url: URL) {
        pasteboard.url = url
    }

    private func shareExternalURL(_ url: URL) {
        sharedActivity = PocketItemActivity(url: url)
    }

    private func openExternalURL(_ url: URL) {
        presentedWebReaderURL = url
    }
}

extension RecommendationViewModel {
    func clearPresentedWebReaderURL() {
        presentedWebReaderURL = nil
    }

    func clearIsPresentingReaderSettings() {
        isPresentingReaderSettings = false
    }

    func clearSharedActivity() {
        sharedActivity = nil
    }

    func clearSelectedRecommendationToReport() {
        selectedRecommendationToReport = nil
    }
}
