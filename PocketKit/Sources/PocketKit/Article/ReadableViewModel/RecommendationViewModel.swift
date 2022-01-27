import Combine
import Sync
import Foundation
import Textile
import UIKit


class RecommendationViewModel: ReadableViewModel {
    weak var delegate: ReadableViewModelDelegate? = nil

    @Published
    private var _actions: [ReadableAction] = []
    var actions: Published<[ReadableAction]>.Publisher { $_actions }

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

    init(recommendation: Slate.Recommendation) {
        self.recommendation = recommendation

        _actions = [
            .save { self.delegate?.readableViewModelDidSave(self) },
            .favorite { self.delegate?.readableViewModelDidFavorite(self) }
        ]
    }

    func shareActivity(additionalText: String?) -> PocketItemActivity? {
        PocketItemActivity(url: url, additionalText: additionalText)
    }

    func delete() { }
}
