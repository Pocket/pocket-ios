// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sails
import SharedPocketKit

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

    static func delete() -> Response {
        fixture(named: "delete")
    }

    static func deleteTag(_ fixtureName: String = "delete-tag-1") -> Response {
        fixture(named: fixtureName)
    }

    static func updateTag() -> Response {
        fixture(named: "update-tag")
    }

    static func archive() -> Response {
        fixture(named: "archive")
    }

    static func favorite() -> Response {
        fixture(named: "favorite")
    }

    static func unfavorite() -> Response {
        fixture(named: "unfavorite")
    }

    static func saveItemFromExtension() -> Response {
        fixture(named: "save-item-from-extension")
    }

    static func emptyList() -> Response {
        fixture(named: "empty-list")
    }

    static func itemDetail() -> Response {
        fixture(named: "item-detail")
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
        fixture(named: "deleteUser")
    }

    static func deleteUserError() -> Response {
        fixture(named: "deleteUser-error")
    }

    static func premiumStatus() -> Response {
        fixture(named: "premium-status")
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

    static func userDetails() -> Response {
        fixture(named: "user")
    }

    static func fixture(named fixtureName: String) -> Response {
        Response {
            Status.ok
            Fixture.data(name: fixtureName)
        }
    }

    static func fallbackResponses(apiRequest: ClientAPIRequest) -> Response {
        if apiRequest.isForSlateLineup {
            return Response.slateLineup()
        } else if apiRequest.isForArchivedContent {
            return Response.archivedContent()
        } else if apiRequest.isForTags {
            return Response.emptyTags()
        } else if apiRequest.isForSavesContent {
            return Response.saves()
        } else if apiRequest.isForDeleteUser {
            return Response.deleteUser()
        } else if apiRequest.isForUserDetails {
            return Response.userDetails()
        } else {
            fatalError("Unexpected request")
        }
    }
}
