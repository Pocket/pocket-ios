// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Foundation
import Localization

extension SavedItem: ItemsListItem {
    var id: String? {
        remoteID
    }

    var domain: String? {
        item?.domain
    }

    var topImageURL: URL? {
        item?.topImageURL
    }

    var timeToRead: Int? {
        item?.timeToRead?.intValue
    }

    var displayTitle: String {
        let itemTitle = item?.title?.isEmpty == false ? item?.title : nil
        return itemTitle ?? item?.bestURL ?? url
    }

    var displayDomain: String? {
        item?.domain ?? item?.domainMetadata?.name ?? host
    }

    var displayDetail: String {
        [displayDomain, displayTimeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    var displayTimeToRead: String? {
        timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { Localization.Item.List.min($0) }
    }

    var displayAuthors: String? {
        let authors: [String]? = item?.authors?.compactMap { ($0 as? Author)?.name }
        return authors?.joined(separator: ", ")
    }

    var host: String? {
        guard let url = URL(percentEncoding: bestURL) else { return nil }
        return url.host
    }

    var tagNames: [String]? {
        tags?.compactMap { $0 as? Tag }.compactMap { $0.name }.sorted()
    }

    var cursor: String? {
        item?.savedItem?.cursor
    }

    var savedItemURL: String {
        url
    }

    var isCollection: Bool {
        item?.isCollection ?? false
    }
}

extension DomainMetadata: ItemsListItemDomainMetadata {
}
