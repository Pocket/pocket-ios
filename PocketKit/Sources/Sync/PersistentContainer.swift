// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

public class PersistentContainer: NSPersistentContainer {
    public lazy var rootSpace = { Space(context: viewContext) }()

    public enum Storage {
        case inMemory
        case shared
    }

    public init(storage: Storage = .shared) {
        ValueTransformer.setValueTransformer(ArticleTransformer(), forName: .articleTransfomer)
        ValueTransformer.setValueTransformer(SyncTaskTransformer(), forName: .syncTaskTransformer)

        let url = Bundle.module.url(forResource: "PocketModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        super.init(name: "PocketModel", managedObjectModel: model)

        switch storage {
        case .inMemory:
            persistentStoreDescriptions = [
                NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            ]
        case .shared:
            let sharedContainerURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.ideashower.ReadItLaterProAlphaNeue")!
                .appendingPathComponent("PocketModel.sqlite")

            persistentStoreDescriptions = [
                NSPersistentStoreDescription(url: sharedContainerURL)
            ]
        }

        loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
