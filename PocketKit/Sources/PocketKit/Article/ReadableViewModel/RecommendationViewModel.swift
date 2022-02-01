import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics


class RecommendationViewModel: ReadableViewModel {
    @Published
    private var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }
    
    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher {
        _events.eraseToAnyPublisher()
    }

    var components: [ArticleComponent]? {
        recommendation.item.article?.components
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

    private let recommendation: Slate.Recommendation
    let mainViewModel: MainViewModel
    let tracker: Tracker

    init(recommendation: Slate.Recommendation, mainViewModel: MainViewModel, tracker: Tracker) {
        self.recommendation = recommendation
        self.mainViewModel = mainViewModel
        self.tracker = tracker

        _actions = [
            .displaySettings { [weak self] in self?.displaySettings() },
            .save { [weak self] in self?.save() },
            .favorite { [weak self] in self?.favorite() },
            .share { [weak self] in self?.share() },
        ]
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
}
