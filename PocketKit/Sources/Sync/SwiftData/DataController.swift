// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//

import Foundation
import SwiftData
import SharedPocketKit

public struct DataController: Sendable {
    public static func makeModelContainer(groupID: String) -> ModelContainer {
        Log.breadcrumb(category: "SWiftUIHome", level: .debug, message: "Start initializing shared model container.")
        ArticleTransformer.register()
        Log.breadcrumb(category: "SWiftUIHome", level: .debug, message: "Article transformer registered.")
        SyncTaskTransformer.register()
        Log.breadcrumb(category: "SWiftUIHome", level: .debug, message: "SynkTask transformer registered.")

        guard let appGroupContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            Log.capture(message: "Shared file container could not be created.")
            fatalError("Shared file container could not be created.")
        }
        let url = appGroupContainer.appendingPathComponent("PocketModel.sqlite")
        do {
            return try ModelContainer(for: Self.schema, configurations: ModelConfiguration(url: url))
        } catch {
            Log.capture(message: "Could not create ModelContainer: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    private static let schema = Schema([
        Author.self,
        Sync.Collection.self,
        CollectionAuthor.self,
        CollectionStory.self,
        DomainMetadata.self,
        FeatureFlag.self,
        Highlight.self,
        Sync.Image.self,
        Item.self,
        PersistentSyncTask.self,
        Recommendation.self,
        SavedItem.self,
        SavedItemUpdatedNotification.self,
        SharedWithYouItem.self,
        Slate.self,
        SlateLineup.self,
        SyndicatedArticle.self,
        Tag.self,
        UnresolvedSavedItem.self
    ])
}
