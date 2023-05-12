// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph
import Sync
import Localization
import SharedPocketKit

extension SearchSavedItem: ItemsListItem {
    var displayTitle: String {
        title ?? ""
    }

    var displayDetail: String {
        [displayDomain, displayTimeToRead]
            .compactMap { $0 }
            .joined(separator: " • ")
    }

    var displayDomain: String? {
        item.asItem?.domainMetadata?.name ?? item.asItem?.domain ?? host
    }

    var displayAuthors: String? {
        let authors = item.asItem?.authors?.compactMap { $0?.name }
        return authors?.joined(separator: ", ")
    }

    var displayTimeToRead: String? {
        timeToRead
            .flatMap { $0 > 0 ? $0 : nil }
            .flatMap { Localization.Item.List.min($0) }
    }

    var remoteItemParts: PocketGraph.SavedItemParts? {
        return remoteItem
    }

    var id: String? {
        item.asItem?.remoteID
    }

    var isFavorite: Bool {
        remoteItem.isFavorite
    }

    var isArchived: Bool {
        remoteItem.isArchived
    }

    var title: String? {
        item.asItem?.title
    }

    var bestURL: URL? {
        guard let itemParts = item.asItem else {
            Log.breadcrumb(category: "search", level: .warning, message: "Skipping updating of Item \(remoteItem.remoteID) because \(item) does not have itemParts")
            return nil
        }

        let resolvedURL = itemParts.resolvedUrl.flatMap(URL.init(string:))
        let givenURL = URL(string: itemParts.givenUrl)
        return resolvedURL ?? givenURL
    }

    var topImageURL: URL? {
        guard let topImageUrl = item.asItem?.topImageUrl else { return nil }
        return URL(string: topImageUrl)
    }

    var domain: String? {
        item.asItem?.domain
    }

    var domainMetadata: ItemsListItemDomainMetadata? {
        item.asItem?.domainMetadata
    }

    var timeToRead: Int? {
        item.asItem?.timeToRead
    }

    var isPending: Bool {
        item.asItem == nil
    }

    var host: String? {
        bestURL?.host
    }

    var tagNames: [String]? {
        remoteItem.tags?.compactMap { $0.name }.sorted()
    }

    var savedItemURL: URL? {
        URL(string: remoteItem.url)
    }
}

extension SavedItemParts.Item.AsItem.DomainMetadata: ItemsListItemDomainMetadata { }
