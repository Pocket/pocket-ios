// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData


extension NSPersistentContainer {
    public static func createDefault() -> NSPersistentContainer {
        ValueTransformer.setValueTransformer(ArticleTransformer(), forName: .articleTransfomer)
        ValueTransformer.setValueTransformer(SyncTaskTransformer(), forName: .syncTaskTransformer)

        let url = Bundle.module.url(forResource: "PocketModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        let container = SharedContainer(name: "PocketModel", managedObjectModel: model)

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        return container
    }
}

private class SharedContainer: NSPersistentContainer {
    override class func defaultDirectoryURL() -> URL {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: "group.com.mozilla.pocket")!
            .appendingPathComponent("pocket.sqlite")
    }
}
