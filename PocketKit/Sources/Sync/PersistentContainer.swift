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
    private (set) var storeDescription: NSPersistentStoreDescription?

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

    public init(storage: Storage = .shared, groupID: String) {
        self.storage = storage

        ValueTransformer.setValueTransformer(ArticleTransformer(), forName: .articleTransfomer)
        ValueTransformer.setValueTransformer(SyncTaskTransformer(), forName: .syncTaskTransformer)

        let url = Bundle.module.url(forResource: "PocketModel", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: url)!
        super.init(name: "PocketModel", managedObjectModel: model)

        switch storage {
        case .inMemory:
            storeDescription = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
        case .shared:
            let sharedContainerURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: groupID)!
                .appendingPathComponent("PocketModel.sqlite")

            Log.debug("Store URL: \(sharedContainerURL)")
            storeDescription = NSPersistentStoreDescription(url: sharedContainerURL)
        }

        guard let storeDescription else {
            fatalError("no store description")
        }

        persistentStoreDescriptions = [
            storeDescription
        ]

        storeDescription.type = NSSQLiteStoreType
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
    }

    /// Attempts to load the persistent container. If the load errors, the persistent container
    /// is destroyed and rebuilt, performing a closure if a reset was necessary.
    /// - Parameter onReset: Called when the persistent container required to be reset
    /// - Note: If a reset was necessary, all previous on-disk data will be removed.
    public func load(onReset: @escaping () -> Void) {
        loadPersistentStores { [weak self] storeDescription, error in
            guard let self else { return }
            if let error = error {
                do {
                    Log.breadcrumb(category: "sync", level: .warning, message: "Error while loading persistent stores; resetting: \(error)")
                    try self.reset(storeDescription: storeDescription)
                    onReset()
                } catch {
                    Log.capture(error: error as NSError)
                    fatalError("[Sync] Unrecoverable error: \(error)")
                }
            }
        }

        guard let storeDescription = persistentStoreDescriptions.first else { return }
        spotlightIndexer = CoreDataSpotlightDelegate(forStoreWith: storeDescription, coordinator: self.persistentStoreCoordinator)
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
