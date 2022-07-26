import Foundation
import Sync
import Combine
import Textile
import CoreData


class HomeRecommendationCellViewModel: NSObject {
    let updated: PassthroughSubject<Void, Never> = .init()
    let recommendation: Recommendation
    var overflowActions: [ItemAction]? = nil
    var saveAction: ItemAction? = nil
    
    var isSaved: Bool {
        resultsController?.fetchedObjects?.first != nil
    }

    private var resultsController: NSFetchedResultsController<SavedItem>?

    init(recommendation: Recommendation) {
        self.recommendation = recommendation

        guard let item = recommendation.item,
              let context = recommendation.managedObjectContext else {
            super.init()
            return
        }

        resultsController = .init(
            fetchRequest: Requests.fetchSavedItem(for: item),
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        super.init()

        try? resultsController?.performFetch()
        resultsController?.delegate = self
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
    }
}

extension HomeRecommendationCellViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updated.send()
    }
}
