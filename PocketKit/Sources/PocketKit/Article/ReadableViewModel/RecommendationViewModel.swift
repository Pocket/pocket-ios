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
    let tracker: Tracker

    private var savedItemCancellable: AnyCancellable? = nil
    private var savedItemSubscriptions: Set<AnyCancellable> = []

    init(recommendation: Recommendation, source: Source, tracker: Tracker) {
        self.recommendation = recommendation
        self.source = source
        self.tracker = tracker

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
        recommendation.item?.authors?.compactMap { $0 as? Author}
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

    func moveToMyList() {
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

    func showWebReader() {
        presentedWebReaderURL = url
    }

    func fetchDetailsIfNeeded() {
        // no op
    }
    
    func externalActions(for url: URL) -> [ItemAction] {
        [
            .save { [weak self] _ in self?.saveExternalURL(url) },
            .open { [weak self] _ in self?.openExternalURL(url) },
            .copyLink { [weak self] _ in self?.copyExternalURL(url) },
            .share { [weak self] _ in self?.shareExternalURL(url) }
        ]
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
            archiveAction = .moveToMyList { [weak self] _ in self?.moveToMyList() }
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

    private func favorite() {
        guard let savedItem = recommendation.item?.savedItem else {
            return
        }

        source.favorite(item: savedItem)
        track(identifier: .itemFavorite)
    }

    private func unfavorite() {
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
        UIPasteboard.general.url = url
    }

    private func shareExternalURL(_ url: URL) {
        sharedActivity = PocketItemActivity(url: url)
    }

    private func openExternalURL(_ url: URL) {
        presentedWebReaderURL = url
    }
}
