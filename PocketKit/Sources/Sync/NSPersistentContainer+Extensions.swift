// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData


extension NSPersistentContainer {
    public static func createDefault() -> NSPersistentContainer {
        let url = Bundle.module.url(forResource: "PocketModel", withExtension: "momd")!

        let model = NSManagedObjectModel(contentsOf: url)!
        return NSPersistentContainer(name: "PocketModel", managedObjectModel: model)
    }
}
