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

    private lazy var modifiedViewContext: NSManagedObjectContext = {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return viewContext
    }()

    public enum Storage {
        case inMemory
        case shared
    }
    private let storage: Storage

    private(set) public var didReset = false

    public init(storage: Storage = .shared, groupID: String) {
        self.storage = storage

        ArticleTransformer.register()
        SyncTaskTransformer.register()

        let url = Bundle.module.url(forResource: "PocketModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        super.init(name: "PocketModel", managedObjectModel: model)

        switch storage {
        case .inMemory:
            persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        case .shared:
            guard let appGroupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
                fatalError("Shared file container could not be created.")
            }

            let url = appGroupContainer.appendingPathComponent("PocketModel.sqlite")

            Log.debug("Store URL: \(url)")
            if let description = persistentStoreDescriptions.first {
                description.url = url
                description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
            }
        }

        loadPersistentStores { [weak self] storeDescription, error in
            guard let self else { return }
            if let error = error {
                do {
                    Log.breadcrumb(category: "sync", level: .warning, message: "Error while loading persistent stores; resetting: \(error)")
                    try self.reset(storeDescription: storeDescription)
                    didReset = true
                } catch {
                    Log.capture(error: error as NSError)
                    fatalError("[Sync] Unrecoverable error: \(error)")
                }
            }
        }

        spotlightIndexer = CoreDataSpotlightDelegate(forStoreWith: persistentStoreDescriptions.first!, coordinator: self.persistentStoreCoordinator)
        spotlightIndexer?.startSpotlightIndexing()
    }
}

private extension PersistentContainer {
    /// Destroys and re-adds a store to the persistent container, clearing out all previous data.
    /// - Parameter storeDescription: The description of the store to re-add on reset.
    func reset(storeDescription: NSPersistentStoreDescription) throws {
        guard let url = storeDescription.url else { return }
        let type = NSPersistentStore.StoreType(rawValue: storeDescription.type)
        try persistentStoreCoordinator.destroyPersistentStore(at: url, type: type)

        loadPersistentStores { _, error in
            if let error = error {
                Log.capture(error: error as NSError)
                fatalError("[Sync] Unrecoverable error: \(error)")
            }
        }
    }
}
