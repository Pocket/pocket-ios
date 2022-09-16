//
//  HomeSharedWithYouCellViewModel.swift
//  
//
//  Created by Daniel Brooks on 8/26/22.
//

import Foundation
import Sync
import Combine
import Textile
import CoreData

class HomeSharedWithYouCellViewModel {
    let sharedWithYou: SharedWithYouHighlight
    let overflowActions: [ItemAction]?
    let primaryAction: ItemAction?

    var isSaved: Bool {
        sharedWithYou.item?.savedItem != nil &&
        sharedWithYou.item?.savedItem?.isArchived == false
    }

    init(
        sharedWithYou: SharedWithYouHighlight,
        overflowActions: [ItemAction]? = nil,
        primaryAction: ItemAction? = nil
    ) {
        self.sharedWithYou = sharedWithYou
        self.overflowActions = overflowActions
        self.primaryAction = primaryAction
    }
}

extension HomeSharedWithYouCellViewModel: HomeCarouselItemCellModel {

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: sharedWithYou.item?.title ?? "", style: .title)
    }

    var attributedDomain: NSAttributedString {
        NSAttributedString(string: domain ?? "", style: .domain)
    }

    var attributedTimeToRead: NSAttributedString {
        NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
    }

    var title: String? {
        sharedWithYou.item?.title
    }

    var saveButtonMode: RecommendationSaveButton.Mode? {
        isSaved ? .saved : .save
    }

    var domain: String? {
        sharedWithYou.item?.domainMetadata?.name ?? sharedWithYou.item?.domain ?? sharedWithYou.item?.bestURL?.host
    }

    var timeToRead: String? {
        guard let timeToRead = sharedWithYou.item?.timeToRead,
              timeToRead > 0 else {
            return nil
        }

        return "\(timeToRead) min read"
    }

    var thumbnailURL: URL? {
        let topImageURL = sharedWithYou.item?.topImageURL
        return imageCacheURL(for: topImageURL)
    }

    var favoriteAction: ItemAction? {
        return nil
    }

    var saveAction: ItemAction? {
        self.primaryAction
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
