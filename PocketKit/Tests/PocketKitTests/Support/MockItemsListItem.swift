// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Localization
@testable import PocketKit

struct MockItemsListItem: ItemsListItem {
    var displayTitle: String {
        title ?? bestURL ?? ""
    }

    var displayDomain: String? {
        domainMetadata?.name ?? domain ?? host
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
        return ""
    }

    let id: String?
    let title: String?
    let isFavorite: Bool
    let isArchived: Bool
    let bestURL: String
    let topImageURL: URL?
    let domain: String?
    let domainMetadata: ItemsListItemDomainMetadata?
    let timeToRead: Int?
    let isPending: Bool
    let host: String?
    let tagNames: [String]?
    let cursor: String?
    let savedItemURL: String

    static func build(
        id: String? = nil,
        title: String? = nil,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        bestURL: String = "https://example.com",
        topImageURL: URL? = nil,
        domain: String? = nil,
        domainMetadata: ItemsListItemDomainMetadata? = nil,
        timeToRead: Int? = nil,
        isPending: Bool = false,
        host: String? = nil,
        tagNames: [String]? = nil,
        cursor: String? = nil,
        savedItemURL: String = "https://example.com"
    ) -> MockItemsListItem {
        MockItemsListItem(
            id: id,
            title: title,
            isFavorite: isFavorite,
            isArchived: isArchived,
            bestURL: bestURL,
            topImageURL: topImageURL,
            domain: domain,
            domainMetadata: domainMetadata,
            timeToRead: timeToRead,
            isPending: isPending,
            host: host,
            tagNames: tagNames,
            cursor: cursor,
            savedItemURL: savedItemURL
        )
    }
}

struct MockItemsListItemDomainMetadata: ItemsListItemDomainMetadata {
    let name: String?
}
