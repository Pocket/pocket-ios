import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics


class RecommendationViewModel: ReadableViewModel {
    let tracker: Tracker

    @Published
    private var _actions: [ItemAction] = []
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
    
    private let recommendation: Slate.Recommendation

    init(recommendation: Slate.Recommendation, tracker: Tracker) {
        self.recommendation = recommendation
        self.tracker = tracker

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() },
            .save { [weak self] _ in self?.save() },
            .favorite { [weak self] _ in self?.favorite() },
            .share { [weak self] _ in self?.share() },
        ]
    }

    var components: [ArticleComponent]? {
        recommendation.item.article?.components
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings()
    }

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: recommendation.item.language)
    }

    var title: String? {
        recommendation.item.title
    }

    var authors: [ReadableAuthor]? {
        recommendation.item.authors
    }

    var domain: String? {
        recommendation.item.domainMetadata?.name ?? recommendation.item.domain
    }

    var publishDate: Date? {
        recommendation.item.datePublished
    }

    var url: URL? {
        recommendation.item.resolvedURL ?? recommendation.item.givenURL
    }

    func delete() { }
}

extension RecommendationViewModel {
    private func save() {
        track(identifier: .itemSave)
    }
    
    private func favorite() {
        track(identifier: .itemFavorite)
    }

    func showWebReader() {
        presentedWebReaderURL = url
    }
}
