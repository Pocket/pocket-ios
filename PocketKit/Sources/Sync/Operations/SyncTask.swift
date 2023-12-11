// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

enum SyncTask: Codable {
    case fetchSaves
    case fetchArchive
    case fetchTags
    case favorite(givenURL: String)
    case unfavorite(givenURL: String)
    case delete(givenURL: String)
    case archive(givenURL: String)
    case save(localID: URL, url: String)
    case addTags(givenURL: String, tags: [String])
    case clearTags(remoteID: String)
    case deleteTag(remoteID: String)
    case renameTag(remoteID: String, name: String)
    case fetchSharedWithYouHighlights(sharedWithYouHighlights: [PocketSWHighlight])
}

public class SyncTaskContainer: NSObject, Codable {
    public static var supportsSecureCoding: Bool = true

    let task: SyncTask

    init(task: SyncTask) {
        self.task = task
        super.init()
    }
}

class SyncTaskTransformer: NSSecureUnarchiveFromDataTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else {
            return nil
        }

        return try? JSONDecoder().decode(SyncTaskContainer.self, from: data)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let syncTaskContainer = value as? SyncTaskContainer else {
            return nil
        }

        return try? JSONEncoder().encode(syncTaskContainer)
    }
}

extension NSValueTransformerName {
    static let syncTaskTransformer = NSValueTransformerName(rawValue: "SyncTaskTransformer")
}
