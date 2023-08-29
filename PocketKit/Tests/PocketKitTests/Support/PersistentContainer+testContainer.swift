// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import Sync

extension PersistentContainer {
    static let testContainer: PersistentContainer = {
        let container = PersistentContainer(storage: .inMemory, groupID: "group.com.ideashower.ReadItLaterPro")
        return container
    }()
}

extension Space {
    static func testSpace() -> Space {
        return PersistentContainer.testContainer.rootSpace
    }
}
