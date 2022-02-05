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
    static let title: Style = .header.sansSerif.h7
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }

    static let detail: Style = .header.sansSerif.p4
        .with(color: .ui.grey4)
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
}

class ItemsListItemPresenter {
    private let item: ItemsListItem

    init(item: ItemsListItem) {
        self.item = item
    }

    var attributedTitle: NSAttributedString {
        NSAttributedString(string: title, style: .title)
    }

    var attributedDetail: NSAttributedString {
        NSAttributedString(string: detail, style: .detail)
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
        item.domainMetadata?.name ?? item.domain
    }

    private var timeToRead: String? {
        item.timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { "\($0) min" }
    }
}
