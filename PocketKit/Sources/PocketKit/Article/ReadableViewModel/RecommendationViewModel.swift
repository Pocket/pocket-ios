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
    
    private let recommendation: Recommendation
    private let source: Source
    let tracker: Tracker

    private var subscriptions: Set<AnyCancellable> = []

    init(recommendation: Recommendation, source: Source, tracker: Tracker) {
        self.recommendation = recommendation
        self.source = source
        self.tracker = tracker

        recommendation.item?.savedItem?.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)

        recommendation.item?.savedItem?.publisher(for: \.isArchived).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &subscriptions)
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
}

extension RecommendationViewModel {
    private func buildActions() {
        guard let savedItem = recommendation.item?.savedItem else {
            _actions = [
                .displaySettings { [weak self] _ in self?.displaySettings() },
                .share { [weak self] _ in self?.share() }
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
}
