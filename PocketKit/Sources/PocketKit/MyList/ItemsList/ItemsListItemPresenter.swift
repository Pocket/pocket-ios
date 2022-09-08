// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import Sync
import Combine
import Foundation
import Sync
import Analytics
import CoreData
import UIKit
import Kingfisher

private extension Style {
    static let title: Style = .header.sansSerif.h8
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
    static let pendingTitle: Style = title.with(color: .ui.grey5)

    static let detail: Style = .header.sansSerif.p4
        .with(color: .ui.grey4)
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
    static let pendingDetail: Style = .detail.with(color: .ui.grey5)
    static let tag: Style = .header.sansSerif.p5.with(color: .ui.grey4).with(weight: .medium).with { paragraph in
        paragraph
            .with(lineBreakMode: .byTruncatingTail)
    }
    static let tagCount: Style = .header.sansSerif.h8.with(color: .ui.grey4)
}

class ItemsListItemPresenter {
    private let item: ItemsListItem

    init(item: ItemsListItem) {
        self.item = item
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title, style: item.isPending ? .pendingTitle : .title)
    }

    var attributedDetail: NSAttributedString {
        NSAttributedString(string: detail, style: item.isPending ? .pendingDetail : .detail)
    }

    var attributedTags: [NSAttributedString]? {
        tags?.map { NSAttributedString(string: $0, style: .tag) }
    }

    var attributedTagCount: NSAttributedString? {
        guard let otherTagsCount = otherTagsCount else { return nil }
        return NSAttributedString(string: "+\(otherTagsCount)", style: .tagCount)
    }

    var thumbnailURL: URL? {
        return imageCacheURL(for: item.topImageURL)
    }

    private var title: String {
        [
            item.title,
            item.bestURL?.absoluteString
        ]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    private var detail: String {
        [domain, timeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    private var domain: String? {
        item.domainMetadata?.name ?? item.domain ?? item.host
    }

    private var tags: [String]? {
        guard let names = item.tagNames else { return nil }
        let tagsCount = min(names.count, 2)
        return tagsCount > 0 ? Array(names[..<tagsCount]) : nil
    }

    private var otherTagsCount: Int? {
        guard let count = item.tagNames?.count else { return nil }
        return count > 2 ? count - 2 : nil
    }

    private var timeToRead: String? {
        item.timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { "\($0) min" }
    }
}
