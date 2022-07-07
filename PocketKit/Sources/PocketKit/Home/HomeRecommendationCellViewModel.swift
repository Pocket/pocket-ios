import Foundation
import Sync
import Combine
import Textile


class HomeRecommendationCellViewModel {
    @Published
    private(set) var isSaved: Bool

    private var subscriptions: Set<AnyCancellable> = []

    let recommendation: Recommendation

    init(recommendation: Recommendation) {
        self.recommendation = recommendation
        isSaved = recommendation.item?.savedItem != nil
        || recommendation.item?.savedItem?.isArchived == false

        // Triggered when an item is explicitly deleted by the user,
        // or when SlateService.fetchSlateLineup(_:) is called
        recommendation.publisher(for: \.item?.savedItem)
            .removeDuplicates()
            .sink { [weak self] savedItem in
                self?.updateIsSaved(with: savedItem != nil)
            }.store(in: &subscriptions)

        recommendation.publisher(for: \.item?.savedItem?.isArchived)
            .compactMap({ $0 })
            .removeDuplicates()
            .sink { [weak self] isArchived in
                self?.updateIsSaved(with: isArchived == false)
            }.store(in: &subscriptions)
    }
}

extension HomeRecommendationCellViewModel {
    func updateIsSaved(with isSaved: Bool) {
        guard isSaved != self.isSaved else {
            return
        }

        self.isSaved = isSaved
    }
}

extension HomeRecommendationCellViewModel: RecommendationCellViewModel {
    var attributedTitle: NSAttributedString {
        NSAttributedString(string: recommendation.item?.title ?? "", style: .title)
    }

    var attributedDetail: NSAttributedString {
        NSAttributedString(string: detail, style: .subtitle)
    }

    var attributedExcerpt: NSAttributedString {
        NSAttributedString(string: recommendation.item?.excerpt ?? "", style: .excerpt)
    }

    var imageURL: URL? {
        let topImageURL = recommendation.item?.topImageURL
        return imageCacheURL(for: topImageURL)
    }

    var saveButtonMode: RecommendationSaveButton.Mode {
        isSaved ? .saved : .save
    }

    private var detail: String {
        [domain, timeToRead].compactMap { $0 }.joined(separator: " • ")
    }

    private var domain: String? {
        recommendation.item?.domainMetadata?.name ?? recommendation.item?.domain ?? recommendation.item?.bestURL?.host
    }

    private var timeToRead: String? {
        guard let timeToRead = recommendation.item?.timeToRead,
              timeToRead > 0 else {
            return nil
        }

        return "\(timeToRead) min"
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h6.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let miniTitle: Style = .header.sansSerif.h7.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let subtitle: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let excerpt: Style = .header.sansSerif.p4.with(color: .ui.grey4).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }
}
