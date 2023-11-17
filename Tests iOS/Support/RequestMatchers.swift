// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sails
import SharedPocketKit

struct ApolloBodyRequest: Codable {
    let operationName: String
    let query: String
    let variables: AnyCodable?

    var variableDict: [String: Any?] {
        variables!.value as! [String: Any?]
    }

    var inputDict: [String: Any?] {
        variableDict["input"] as! [String: Any?]
    }
}

struct ClientAPIRequest {
    private let request: Request
    private let requestBody: String?
    private let apolloRequestBody: ApolloBodyRequest?
    private let operationName: String?

    init(_ request: Request) {
        self.request = request
        self.requestBody = body(of: request)
        do {
            self.apolloRequestBody = try JSONDecoder().decode(ApolloBodyRequest.self, from: self.request.body!)
            self.operationName = self.apolloRequestBody?.operationName
        } catch {
            fatalError("could not parse apollo body \(error)")
        }
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
        self.operationName == "HomeSlateLineup"
    }

    var isToArchiveAnItem: Bool {
        self.operationName == "ArchiveItem"
    }

    var isToDeleteATag: Bool {
        self.operationName == "DeleteTag"
    }

    var isToUpdateTag: Bool {
        self.operationName == "TagUpdate"
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

    func isToSaveAnItem(with url: URL) -> Bool {
        isToSaveAnItem && self.inputURL == url
    }

    var isForItemDetail: Bool {
        self.operationName == "SavedItemByID"
    }

    var isForArchivedItemDetail: Bool {
        self.operationName == "SavedItemByID" && contains("archived-item-1")
    }

    func isForRecommendationDetail(_ rec: String) -> Bool {
        self.operationName == "ItemByURL" && contains(rec)
    }

    var isForReplacingSavedItemTags: Bool {
        self.operationName == "ReplaceSavedItemTags"
    }

    var isForTags: Bool {
        self.operationName == "Tags"
    }

    var isForSaveTags: Bool {
        self.operationName == "SavedItemTag"
    }

    var isForCollection: Bool {
        self.operationName == "getCollectionBySlug"
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
        case .premiumSearchByTitle:
            return self.operationName == "SearchSavedItems" && contains("filter\":{\"onlyTitleAndURL\"}")
        case .premiumSearchByTag:
            return self.operationName == "SearchSavedItems" && contains("filter\":{}") && contains("tag:")
        case .premiumSearchByContent:
            return self.operationName == "SearchSavedItems" && contains("filter\":{}")
        }
    }

    var isForFeatureFlags: Bool {
        self.operationName == "FeatureFlags"
    }

    func contains(_ string: String) -> Bool {
        requestBody?.contains(string) == true
    }
}

extension ClientAPIRequest {
    var variableItemId: String {
        self.apolloRequestBody!.variableDict["itemID"] as! String
    }

    var variableId: String {
        self.apolloRequestBody!.variableDict["id"] as! String
    }

    var inputId: String {
        self.apolloRequestBody!.inputDict["id"] as! String
    }

    var inputName: String {
        self.apolloRequestBody!.inputDict["id"] as! String
    }

    var inputURL: URL {
        URL(string: self.apolloRequestBody!.inputDict["url"] as! String)!
    }

    var givenURL: URL {
        URL(string: self.apolloRequestBody!.inputDict["givenUrl"] as! String)!
    }

    var variableGivenURL: String {
        apolloRequestBody!.variableDict["givenUrl"] as! String
    }
}
