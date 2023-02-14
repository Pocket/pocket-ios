import Foundation
import UIKit
import Textile

class RecentSavesItemCell: HomeCarouselItemCell {
    struct Model: HomeCarouselItemCellModel {
        let item: ItemsListItem
        let favoriteAction: ItemAction?
        let overflowActions: [ItemAction]?
        let thumbnailURL: URL?

        // Unused properties for recent saves cells
        let saveButtonMode: RecommendationSaveButton.Mode? = nil
        let saveAction: ItemAction? = nil

        init(
            item: ItemsListItem,
            favoriteAction: ItemAction?,
            overflowActions: [ItemAction]?
        ) {
            self.item = item
            self.favoriteAction = favoriteAction
            self.overflowActions = overflowActions
            self.thumbnailURL = imageCacheURL(for: item.topImageURL)
        }

        var attributedTitle: NSAttributedString {
            NSAttributedString(string: title, style: .title)
        }

        var attributedDomain: NSAttributedString {
            return NSAttributedString(string: domain ?? "", style: .domain)
        }

        var attributedTimeToRead: NSAttributedString {
            return NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
        }

        private var domain: String? {
            item.domainMetadata?.name ?? item.domain ?? item.bestURL.host
        }

        private var title: String {
            [
                item.title,
                item.bestURL.absoluteString
            ]
                .compactMap { $0 }
                .first { !$0.isEmpty } ?? ""
        }

        private var timeToRead: String? {
            guard let timeToRead = item.timeToRead,
                  timeToRead > 0 else {
                return nil
            }

            return L10n.minRead(timeToRead)
        }
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with { paragraph in
        paragraph.with(lineSpacing: 4).with(lineBreakMode: .byTruncatingTail)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }

    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 22)
}
