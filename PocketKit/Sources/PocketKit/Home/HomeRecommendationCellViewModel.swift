import Foundation
import Sync
import Combine
import Textile
import CoreData

class HomeRecommendationCellViewModel {
    let recommendation: Recommendation
    let overflowActions: [ItemAction]?
    let primaryAction: ItemAction?

    var isSaved: Bool {
        recommendation.item?.savedItem != nil &&
        recommendation.item?.savedItem?.isArchived == false
    }

    init(
        recommendation: Recommendation,
        overflowActions: [ItemAction]? = nil,
        primaryAction: ItemAction? = nil
    ) {
        self.recommendation = recommendation
        self.overflowActions = overflowActions
        self.primaryAction = primaryAction
    }
}

extension HomeRecommendationCellViewModel: RecommendationCellViewModel {
    var attributedTitle: NSAttributedString {
        NSAttributedString(string: recommendation.item?.title ?? "", style: .title)
    }

    var attributedDomain: NSAttributedString {
        NSAttributedString(string: domain ?? "", style: .domain)
    }

    var attributedTimeToRead: NSAttributedString {
        NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
    }

    var title: String? {
        recommendation.item?.title
    }

    var imageURL: URL? {
        let topImageURL = recommendation.item?.topImageURL
        return imageCacheURL(for: topImageURL)
    }

    var saveButtonMode: RecommendationSaveButton.Mode {
        isSaved ? .saved : .save
    }

    var domain: String? {
        recommendation.item?.domainMetadata?.name ?? recommendation.item?.domain ?? recommendation.item?.bestURL?.host
    }

    var timeToRead: String? {
        guard let timeToRead = recommendation.item?.timeToRead,
              timeToRead > 0 else {
            return nil
        }

        return "\(timeToRead) min read"
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h6.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail).with(lineSpacing: 4)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
