// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sails
import SharedPocketKit
import ApolloTestSupport
import Apollo
import PocketGraphTestMocks
import NIOCore
import Foundation

extension Response {
    static func saves(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func freeUserSaves(_ fixtureName: String = "initial-list") -> Response {
        saves("initial-list-free-user")
    }

    static func archivedContent() -> Response {
        saves("archived-items")
    }

    static func favoritedArchivedContent() -> Response {
        saves("archived-favorite-items")
    }

    static func slateLineup(_ fixtureName: String = "slates") -> Response {
        fixture(named: fixtureName)
    }

    static func slateDetail(_ number: Int = 1) -> Response {
        fixture(named: "slate-detail-\(number)")
    }

    static func saveItem(_ fixtureName: String = "save-item") -> Response {
        fixture(named: fixtureName)
    }

    static func delete(apiRequest: ClientAPIRequest) -> Response {
        return Response(
            status: .ok,
            content: Mock<Mutation>(
                deleteSavedItem: apiRequest.itemIdVariable
            )._selectionSetMockData
        )
    }

    static func deleteTag(apiRequest: ClientAPIRequest) -> Response {
        return Response(
            status: .ok,
            content: Mock<Mutation>(
                deleteTag: apiRequest.idVariable
            )._selectionSetMockData
        )
    }

    static func updateTag() -> Response {
        fixture(named: "update-tag")
    }

    static func archive(apiRequest: ClientAPIRequest) -> Response {
        return Response(
            status: .ok,
            content: Mock<Mutation>(
                updateSavedItemArchive: Mock<SavedItem>(
                    id: apiRequest.itemIdVariable
                )
            )._selectionSetMockData
        )
    }

    static func favorite(apiRequest: ClientAPIRequest) -> Response {
        return Response(
            status: .ok,
            content: Mock<Mutation>(
                updateSavedItemFavorite: Mock<SavedItem>(
                    id: apiRequest.itemIdVariable
                )
            )._selectionSetMockData
        )
    }

    static func unfavorite(apiRequest: ClientAPIRequest) -> Response {
        return Response(
            status: .ok,
            content: Mock<Mutation>(
                updateSavedItemUnFavorite: Mock<SavedItem>(
                    id: apiRequest.itemIdVariable
                )
            )._selectionSetMockData
        )
    }

    static func saveItemFromExtension() -> Response {
        fixture(named: "save-item-from-extension")
    }

    static func emptyList() -> Response {
        fixture(named: "empty-list")
    }

    static func itemDetail() -> Response {
        return Response {
            Status.ok
            Fixture.load(name: "item-detail")
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func archiveItemDetail() -> Response {
        return Response {
            Status.ok
            Fixture.load(name: "archive-item-detail")
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func recommendationDetail(_ number: Int = 1) -> Response {
        fixture(named: "recommendation-detail-\(number)")
    }

    static func savedItemWithTag() -> Response {
        fixture(named: "list-with-tagged-item")
    }

    static func emptyTags() -> Response {
        fixture(named: "empty-tags")
    }

    static func deleteUser() -> Response {
        return Response(
            status: .ok,
            content: Mock<Mutation>(
                deleteUser: "fake-user-id"
            )._selectionSetMockData
        )
    }

    static func deleteUserError() -> Response {
        fixture(named: "deleteUser-error")
    }

    static func premiumStatus() -> Response {
        fixture(named: "premium-status")
    }

    static func userDetails() -> Response {
        return Response(
            status: .ok,
            content: Mock<Query>(
                user: Mock<PocketGraphTestMocks.User>(
                    isPremium: false,
                    name: "Pocket User",
                    username: "User Name"
                )
            )._selectionSetMockData
        )
    }

    static func premiumUserDetails() -> Response {
        return Response(
            status: .ok,
            content: Mock<Query>(
                user: Mock<PocketGraphTestMocks.User>(
                    isPremium: true,
                    name: "Pocket User",
                    username: "User Name"
                )
            )._selectionSetMockData
        )
    }

    static func searchList(_ type: SearchScope) -> Response {
        var fixtureName = "search-list"
        switch type {
        case .saves:
            fixtureName = "search-list"
        case .archive:
            fixtureName = "search-list-archive"
        case .all:
            fixtureName = "search-list-all"
        }

        return Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func searchPagination(_ fixtureName: String = "search-list-page-1") -> Response {
        fixture(named: fixtureName)
    }

    static func featureFlags(_ fixtureName: String = "feature-flags") -> Response {
        fixture(named: fixtureName)
    }

    static func fixture(named fixtureName: String) -> Response {
        Response {
            Status.ok
            Fixture.data(name: fixtureName)
        }
    }

    static func fallbackResponses(apiRequest: ClientAPIRequest) -> Response {
        if apiRequest.isForSlateLineup {
            return .slateLineup()
        } else if apiRequest.isForSlateDetail(1) {
            return Response.slateDetail(1)
        } else if apiRequest.isForSlateDetail(2) {
            return Response.slateDetail(2)
        } else if apiRequest.isForArchivedContent {
            return .archivedContent()
        } else if apiRequest.isForTags {
            return .emptyTags()
        } else if apiRequest.isForSavesContent {
            return .saves()
        } else if apiRequest.isForDeleteUser {
            return .deleteUser()
        } else if apiRequest.isForUserDetails {
            return .userDetails()
        } else if apiRequest.isToArchiveAnItem {
            return .archive(apiRequest: apiRequest)
        } else if apiRequest.isToSaveAnItem {
            return .saveItem()
        } else if apiRequest.isForRecommendationDetail(1) {
            return .recommendationDetail(1)
        } else if apiRequest.isForRecommendationDetail(2) {
            return .recommendationDetail(2)
        } else if apiRequest.isForRecommendationDetail(3) {
            return .recommendationDetail(3)
        } else if apiRequest.isForRecommendationDetail(4) {
            return .recommendationDetail(4)
        } else if apiRequest.isForArchivedItemDetail {
            return .archiveItemDetail()
        } else if apiRequest.isForItemDetail {
            return .itemDetail()
        } else if apiRequest.isForReplacingSavedItemTags {
            return .savedItemWithTag()
        } else if apiRequest.isToFavoriteAnItem {
            return .favorite(apiRequest: apiRequest)
        } else if apiRequest.isToUnfavoriteAnItem {
            return .unfavorite(apiRequest: apiRequest)
        } else if apiRequest.isToDeleteAnItem {
            return .delete(apiRequest: apiRequest)
        } else if apiRequest.isToDeleteATag {
            return .deleteTag(apiRequest: apiRequest)
        } else if apiRequest.isForSearch(.all) {
            return .searchList(.all)
        } else if apiRequest.isForSearch(.saves) {
            return .searchList(.saves)
        } else if apiRequest.isForSearch(.archive) {
            return .searchList(.archive)
        } else if apiRequest.isForFeatureFlags {
            return .featureFlags()
        } else {
            fatalError("Unexpected request")
        }
    }
}

extension JSONObject: Content {
    public func encode(to buffer: inout ByteBuffer) throws -> Int {
        return try buffer.writeData(JSONSerializationFormat.serialize(value: self))
    }
}
