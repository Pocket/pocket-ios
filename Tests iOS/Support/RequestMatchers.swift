// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sails

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

    var isForMyListContent: Bool {
        contains("userByToken") && !contains(#""isArchived":true"#)
    }

    var isForArchivedContent: Bool {
        contains("savedItems(") && contains(#""isArchived":true"#)
    }

    var isForFavoritedArchivedContent: Bool {
        contains("savedItems(") && contains(#""isArchived":true"#) && contains(#""isFavorite":true"#)
    }

    var isForSlateLineup: Bool {
        contains("getSlateLineup")
    }

    var isToArchiveAnItem: Bool {
        contains("updateSavedItemArchive")
    }

    var isToDeleteAnItem: Bool {
        contains("deleteSavedItem")
    }

    var isToFavoriteAnItem: Bool {
        contains("updateSavedItemFavorite")
    }

    var isToUnfavoriteAnItem: Bool {
        contains("updateSavedItemUnFavorite")
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

    var isForRecommendationDetail: Bool {
        contains("itemByItemId(")
    }

    var isForReplacingSavedItemTags: Bool {
        contains("replaceSavedItemTags")
    }

    func contains(_ string: String) -> Bool {
        requestBody?.contains(string) == true
    }
}
