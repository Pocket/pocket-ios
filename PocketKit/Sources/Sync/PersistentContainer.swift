// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData

public class PersistentContainer: NSPersistentContainer {
    public lazy var rootSpace = { Space(backgroundContext: backgroundContext, viewContext: modifiedViewContext) }()

    private lazy var backgroundContext = {
        let context = newBackgroundContext()
        return context
    }()

    lazy var modifiedViewContext: NSManagedObjectContext = {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }()

    public enum Storage {
        case inMemory
        case shared
    }

    let userDefaults: UserDefaults

    public init(storage: Storage = .shared, userDefaults: UserDefaults, groupID: String) {
        self.userDefaults = userDefaults

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
                .containerURL(forSecurityApplicationGroupIdentifier: groupID)!
                .appendingPathComponent("PocketModel.sqlite")

            Log.debug("Store URL: \(sharedContainerURL)")
            persistentStoreDescriptions = [
                NSPersistentStoreDescription(url: sharedContainerURL)
            ]
        }

        loadPersistentStores {storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}
