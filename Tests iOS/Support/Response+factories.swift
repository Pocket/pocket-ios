// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sails

extension Response {
    static func saves(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
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

    static func recommendationDetail() -> Response {
        fixture(named: "recommendation-detail")
    }

    static func savedItemWithTag() -> Response {
        fixture(named: "list-with-tagged-item")
    }

    static func emptyTags() -> Response {
        fixture(named: "empty-tags")
    }

    static func searchList() -> Response {
        fixture(named: "search-list")
    }

    static func fixture(named fixtureName: String) -> Response {
        Response {
            Status.ok
            Fixture.data(name: fixtureName)
        }
    }
}
