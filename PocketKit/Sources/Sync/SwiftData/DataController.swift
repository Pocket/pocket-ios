// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData

@MainActor
public class DataController {
    public static var appGroupContainerID: String?

    public static let schema = Schema([
//        Author.self,
//        Sync.Collection.self,
//        CollectionAuthor.self,
//        CollectionStory.self,
//        DomainMetadata.self,
        FeatureFlag.self,
//        Highlight.self,
//        Sync.Image.self,
//        Item.self,
//        PersistentSyncTask.self,
//        Recommendation.self,
//        SavedItem.self,
//        SavedItemUpdatedNotification.self,
//        SharedWithYouItem.self,
//        Slate.self,
//        SlateLineup.self,
//        SyndicatedArticle.self,
//        Tag.self,
//        UnresolvedSavedItem.self
    ])

    public static let previewContainer: ModelContainer = {
        ArticleTransformer.register()
        SyncTaskTransformer.register()
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: config)
            MockData.insertFakeData(container: container)
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()

    public static let sharedModelContainer: ModelContainer = {
        ArticleTransformer.register()
        SyncTaskTransformer.register()

        guard let appGroupContainerID = appGroupContainerID else {
            fatalError("appGroupContainerID must be set before accessing the sharedModelContainer.")
        }
        guard let appGroupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupContainerID) else {
            fatalError("Shared file container could not be created.")
        }
        let url = appGroupContainer.appendingPathComponent("PocketModel.sqlite")
        do {
            return try ModelContainer(for: schema, configurations: ModelConfiguration(url: url))
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
