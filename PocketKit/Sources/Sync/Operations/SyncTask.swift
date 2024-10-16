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
    case replaceTags(remoteID: String, tags: [String])
    case clearTags(remoteID: String)
    case deleteTag(remoteID: String)
    case renameTag(remoteID: String, name: String)
    case deleteHighlight(remoteID: String)
    case createHighlight(quote: String, patch: String, version: Int, itemId: String)
    case fetchSharedWithYouItems(urls: [String])
}

@objc(SyncTaskContainer)
public class SyncTaskContainer: NSObject, Codable {
    public static var supportsSecureCoding: Bool = true

    let task: SyncTask

    init(task: SyncTask) {
        self.task = task
        super.init()
    }
}

@objc(SyncTaskTransformer)
class SyncTaskTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: SyncTaskTransformer.self))

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

        return try? JSONEncoder().encode(syncTaskContainer) as NSData
    }

    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    public static func register() {
        let transformer = SyncTaskTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
