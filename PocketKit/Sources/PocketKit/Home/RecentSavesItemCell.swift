import Foundation
import UIKit
import Textile

class RecentSavesItemCell: HomeCarouselItemCell {
    struct Model: HomeCarouselItemCellModel {
        let item: ItemsListItem
        let thumbnailURL: URL?
        let saveButtonMode: RecommendationSaveButton.Mode?
        
        init(item: ItemsListItem) {
            self.item = item
            self.thumbnailURL = imageCacheURL(for: item.topImageURL)
            self.saveButtonMode = nil
        }
        
        var favoriteAction: ItemAction? = nil
        var saveAction: ItemAction? = nil
        var overflowActions: [ItemAction]? = nil
        
        var attributedTitle: NSAttributedString {
            NSAttributedString(string: item.title ?? "", style: .title)
        }
        
        var attributedDomain: NSAttributedString {
            return NSAttributedString(string: domain ?? "", style: .domain)
        }
        
        var attributedTimeToRead: NSAttributedString {
            return NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
        }
        
        private var domain: String? {
            item.domainMetadata?.name ?? item.domain ?? item.bestURL?.host
        }
        
        private var timeToRead: String? {
            guard let timeToRead = item.timeToRead,
                  timeToRead > 0 else {
                return nil
            }

            return "\(timeToRead) min read"
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
    }
}
