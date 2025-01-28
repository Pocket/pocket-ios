// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Combine
import Foundation
import Analytics
import CoreData
import UIKit
import Kingfisher
import Localization
import SharedPocketKit

class ItemsListItemPresenter {
    private let item: ItemsListItem
    private let isDisabled: Bool

    init(item: ItemsListItem, isDisabled: Bool = false) {
        self.item = item
        self.isDisabled = isDisabled
    }

    var attributedCollection: NSAttributedString? {
        guard item.isCollection else { return nil }
        return NSAttributedString(string: Localization.Constants.collection, style: .recommendation.collection)
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title, style: isDisabled ? .listCellPendingTitle : .listCellTitle)
    }

    var attributedDetail: NSAttributedString {
        let detailString = NSMutableAttributedString(string: detail, style: isDisabled ? .listCellPendingDetail : .listCellDetail)
        return item.isSyndicated ? detailString.addSyndicatedIndicator(with: isDisabled ? .listCellPendingDetail : .listCellDetail) : detailString
    }

    var attributedTags: [NSAttributedString]? {
        tags?.map { NSAttributedString(string: $0, style: .listCellTag) }
    }

    var attributedTagCount: NSAttributedString? {
        guard let otherTagsCount = otherTagsCount else { return nil }
        return NSAttributedString(string: "+\(otherTagsCount)", style: .listCellTagCount)
    }

    var thumbnailURL: URL? {
        return CDNURLBuilder().imageCacheURL(for: item.topImageURL)
    }

    var hasHighlights: Bool {
        item.hasHighlights
    }

    var highlightsCount: Int {
        item.highlightsCount
    }

    private var title: String {
        item.displayTitle
    }

    private var detail: String {
        item.displayDetail
    }

    private var domain: String? {
        item.displayDomain
    }

    private var tags: [String]? {
        guard let names = item.tagNames else { return nil }
        let highlightAddOn = hasHighlights ? 1 : 0
        let tagsCount = min(names.count, 2 - highlightAddOn)
        return tagsCount > 0 ? Array(names[..<tagsCount]) : nil
    }

    private var otherTagsCount: Int? {
        guard let count = item.tagNames?.count else { return nil }
        let highlightAddOn = hasHighlights ? 1 : 0
        return count + highlightAddOn > 2 ? count + highlightAddOn - 2 : nil
    }

    private var timeToRead: String? {
        item.timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { Localization.Item.List.min($0) }
    }
}
