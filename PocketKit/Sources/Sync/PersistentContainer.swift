// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import CoreData
import SharedPocketKit

public class PersistentContainer: NSPersistentContainer {
    public lazy var rootSpace = { Space(backgroundContext: backgroundContext, viewContext: modifiedViewContext) }()

    private lazy var backgroundContext = {
        let context = newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()

    private (set) var spotlightIndexer: CoreDataSpotlightDelegate?
    private (set) var storeDescription: NSPersistentStoreDescription!

    private lazy var modifiedViewContext: NSManagedObjectContext = {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }()

    public enum Storage {
        case inMemory
        case shared
    }

    public init(storage: Storage = .shared, groupID: String) {
        ValueTransformer.setValueTransformer(ArticleTransformer(), forName: .articleTransfomer)
        ValueTransformer.setValueTransformer(SyncTaskTransformer(), forName: .syncTaskTransformer)

        let url = Bundle.module.url(forResource: "PocketModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        super.init(name: "PocketModel", managedObjectModel: model)

        storeDescription = getStoreDescription(with: storage, groupID)

        persistentStoreDescriptions = [
            storeDescription
        ]

        storeDescription.type = NSSQLiteStoreType
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        loadPersistentStores {storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        spotlightIndexer = CoreDataSpotlightDelegate(forStoreWith: storeDescription, coordinator: self.persistentStoreCoordinator)
        spotlightIndexer?.startSpotlightIndexing()
    }

    private func getStoreDescription(with storage: Storage, _ groupID: String) -> NSPersistentStoreDescription {
        if case .shared = storage {
            guard let sharedContainerURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: groupID)?
                .appendingPathComponent("PocketModel.sqlite") else {
                Log.warning("Invalid GroupID \(groupID). Falling back to inMemory Storage")

                return NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            }

            Log.debug("Store URL: \(sharedContainerURL)")
            return NSPersistentStoreDescription(url: sharedContainerURL)
        }

        return NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
    }
}
