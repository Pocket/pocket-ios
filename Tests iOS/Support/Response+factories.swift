// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sails


extension Response {
    static func myList(_ fixtureName: String = "initial-list") -> Response {
        Response {
            Status.ok
            Fixture.load(name: fixtureName)
                .replacing("MARTICLE", withFixtureNamed: "marticle")
                .data
        }
    }

    static func archivedContent() -> Response {
        myList("archived-items")
    }
    
    static func favoritedArchivedContent() -> Response {
        myList("archived-favorite-items")
    }

    static func slateLineup(_ fixtureName: String = "slates") -> Response {
        fixture(named: fixtureName)
    }

    static func slateDetail() -> Response {
        fixture(named: "slate-detail")
    }

    static func saveItem() -> Response {
        fixture(named: "save-item")
    }

    static func delete() -> Response {
        fixture(named: "delete")
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

    private static func fixture(named fixtureName: String) -> Response {
        Response {
            Status.ok
            Fixture.data(name: fixtureName)
        }
    }
}
