// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData
import Fakery

@available(iOS 17, *)
@MainActor
class MockData {
    /**
     Inserts fake data for the model to be used in previews or ui testing.
     */
    static func insertFakeData(container: ModelContainer) {
        let faker = Faker(locale: "en-US")
        var items: [Item] = []
        for _ in 0...5 {
            let item = Item(givenURL: faker.internet.url(), remoteID: String(faker.number.increasingUniqueId()))
            item.title = faker.lorem.words(amount: 8)
            item.excerpt = faker.lorem.sentences(amount: 2)
            items.append(item)
        }

        for item in items {
            container.mainContext.insert(item)
        }

        // TODO: Random generate everything.
    }
}
