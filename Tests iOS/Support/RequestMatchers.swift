// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sails
import SharedPocketKit

struct ClientAPIRequest {
    private let request: Request
    private let requestBody: String?

    init(_ request: Request) {
        self.request = request
        self.requestBody = body(of: request)
    }

    var isEmpty: Bool {
        requestBody == nil
    }

    var isForSavesContent: Bool {
        contains("FetchSaves") && !contains(#"ARCHIVED"#)
    }

    var isForArchivedContent: Bool {
        contains("FetchArchive") && contains(#"ARCHIVED"#)
    }

    var isForSlateLineup: Bool {
        contains("getSlateLineup")
    }

    var isToArchiveAnItem: Bool {
        contains("updateSavedItemArchive")
    }

    func isToDeleteATag(_ number: Int = 1) -> Bool {
        contains("deleteTag(") && contains("id-\(number)")
    }

    func isToUpdateTag(_ name: String) -> Bool {
        contains("updateTag(") && contains("\(name)")
    }

    var isToDeleteAnItem: Bool {
        contains("deleteSavedItem")
    }

    func isToFavoriteAnItem(_ number: Int = 1) -> Bool {
        contains("updateSavedItemFavorite") && contains("item-\(number)")
    }

    func isToUnfavoriteAnItem(_ number: Int = 1) -> Bool {
        contains("updateSavedItemUnFavorite") && contains("item-\(number)")
    }

    func isForSlateDetail(_ number: Int = 1) -> Bool {
        contains("getSlate(") && contains("slate-\(number)")
    }

    var isToSaveAnItem: Bool {
        contains("upsertSavedItem")
    }

    var isForItemDetail: Bool {
        contains("savedItemById(")
    }

    func isForRecommendationDetail(_ number: Int = 1) -> Bool {
        contains("itemByItemId(") && contains("recommended-item-\(number)")
    }

    var isForReplacingSavedItemTags: Bool {
        contains("replaceSavedItemTags")
    }

    var isForTags: Bool {
        contains("Tags")
    }

    var isForDeleteUser: Bool {
        contains("deleteUser")
    }

    var isForUserDetails: Bool {
        contains("user")
    }

    func isForSearch(_ type: SearchScope) -> Bool {
        switch type {
        case .saves:
            return contains("searchSavedItems") && contains("filter\":{\"status\":\"UNREAD\"}")
        case .archive:
            return contains("searchSavedItems") && contains("filter\":{\"status\":\"ARCHIVED\"}")
        case .all:
            return contains("searchSavedItems") && contains("filter\":{}")
        }
    }

    func contains(_ string: String) -> Bool {
        requestBody?.contains(string) == true
    }
}
