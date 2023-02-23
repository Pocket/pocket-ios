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

    let userDefaults: UserDefaults

    public init(storage: Storage = .shared, userDefaults: UserDefaults) {
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
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.ideashower.ReadItLaterProAlphaNeue")!
                .appendingPathComponent("PocketModel.sqlite")

            removeDatabaseIfNeeded(sharedContainerURL: FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.ideashower.ReadItLaterProAlphaNeue")!)

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

public extension PersistentContainer {
    static let hasResetData2212023Key = "PersistentContainer.reset.data.02.21.2023"

    var hasResetData2212023: Bool {
        get {
            userDefaults.bool(forKey: Self.hasResetData2212023Key)
        }
        set {
            userDefaults.set(newValue, forKey: Self.hasResetData2212023Key)
        }
    }

    /**
     During our Testflight, we merged a change that made values non-null in CoreData. Turns out that we were unknowningly saving null values in fields that should have been required.
     Instead of coding a whole core data migration, this wipes the core data store and sets a flag to not wipe it again.
     This can safely be removed some time after our MVP launch and is a stop gap for now. In the future we will use proper CoreData migrations.
     */
    func removeDatabaseIfNeeded(sharedContainerURL: URL!) {
        if !hasResetData2212023 {
            do {
                try FileManager.default.removeItem(at: sharedContainerURL.appendingPathComponent("PocketModel.sqlite"))
                try FileManager.default.removeItem(at: sharedContainerURL.appendingPathComponent("PocketModel.sqlite-shm"))
                try FileManager.default.removeItem(at: sharedContainerURL.appendingPathComponent("PocketModel.sqlite-wal"))
            } catch {
                // Capture error and move on.
                Log.capture(error: error)
            }
            // Uses the .standard user defaults here because thats where we store it in PocketSource.
            UserDefaultsLastRefresh(defaults: .standard).reset()
            hasResetData2212023 = true
        }
    }
}
