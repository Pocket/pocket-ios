// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph

protocol ItemsListItem {
    var id: String? { get }
    var displayTitle: String { get }
    var displayDetail: String { get }
    var isFavorite: Bool { get }
    var isArchived: Bool { get }
    var bestURL: String { get }
    var topImageURL: URL? { get }
    var displayDomain: String? { get }
    var displayAuthors: String? { get }
    var displayTimeToRead: String? { get }
    var timeToRead: Int? { get }
    var isPending: Bool { get }
    var host: String? { get }
    var tagNames: [String]? { get }
    var remoteItemParts: SavedItemParts? { get }
    var savedItemURL: String { get }
    var cursor: String? { get }
    var isCollection: Bool { get }
    var isSyndicated: Bool { get }
    var hasHighlights: Bool { get }
    var highlightsCount: Int { get }
}

extension ItemsListItem {
    var remoteItemParts: SavedItemParts? {
        return nil
    }
}

protocol ItemsListItemDomainMetadata {
    var name: String? { get }
}
