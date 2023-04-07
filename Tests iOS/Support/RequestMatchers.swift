// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sails
import SharedPocketKit

struct ClientAPIRequest {
    private let request: Request
    private let requestBody: String?
    private let operationName: String?

    init(_ request: Request) {
        self.request = request
        self.requestBody = body(of: request)
        self.operationName = request.head.headers.first(name: "X-APOLLO-OPERATION-NAME")
    }

    var isEmpty: Bool {
        requestBody == nil
    }

    var isForSavesContent: Bool {
        self.operationName == "FetchSaves" && !contains(#"ARCHIVED"#)
    }

    var isForArchivedContent: Bool {
        self.operationName == "FetchArchive" && contains(#"ARCHIVED"#)
    }

    var isForSlateLineup: Bool {
        self.operationName == "GetSlateLineup"
    }

    var isToArchiveAnItem: Bool {
        self.operationName == "ArchiveItem"
    }

    func isToDeleteATag(_ number: Int = 1) -> Bool {
        self.operationName == "DeleteTag" && contains("id-\(number)")
    }

    func isToUpdateTag(_ name: String) -> Bool {
        self.operationName == "TagUpdate" && contains("\(name)")
    }

    var isToDeleteAnItem: Bool {
        self.operationName == "DeleteItem"
    }

    var isToFavoriteAnItem: Bool {
        self.operationName == "FavoriteItem"
    }

    var isToUnfavoriteAnItem: Bool {
        self.operationName == "UnfavoriteItem"
    }

    func isForSlateDetail(_ number: Int = 1) -> Bool {
        self.operationName == "GetSlate" && contains("slate-\(number)")
    }

    var isToSaveAnItem: Bool {
        self.operationName == "SaveItem"
    }

    var isForItemDetail: Bool {
        self.operationName == "SavedItemByID"
    }

    var isForArchivedItemDetail: Bool {
        self.operationName == "SavedItemByID" && contains("archived-item-1")
    }

    func isForRecommendationDetail(_ number: Int = 1) -> Bool {
        self.operationName == "ItemByID" && contains("recommended-item-\(number)")
    }

    var isForReplacingSavedItemTags: Bool {
        self.operationName == "ReplaceSavedItemTags"
    }

    var isForTags: Bool {
        self.operationName == "Tags"
    }

    var isForDeleteUser: Bool {
        self.operationName == "DeleteUser"
    }

    var isForUserDetails: Bool {
        self.operationName == "GetUserData"
    }

    func isForSearch(_ type: SearchScope) -> Bool {
        switch type {
        case .saves:
            return self.operationName == "SearchSavedItems" && contains("filter\":{\"status\":\"UNREAD\"}")
        case .archive:
            return self.operationName == "SearchSavedItems" && contains("filter\":{\"status\":\"ARCHIVED\"}")
        case .all:
            return self.operationName == "SearchSavedItems" && contains("filter\":{}")
        }
    }

    func contains(_ string: String) -> Bool {
        requestBody?.contains(string) == true
    }
}
