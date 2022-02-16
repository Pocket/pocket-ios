import Foundation

enum SyncTask: Codable {
    case fetchList(maxItems: Int)
    case favorite(remoteID: String)
    case unfavorite(remoteID: String)
    case delete(remoteID: String)
    case archive(remoteID: String)
    case unarchive(remoteID: String)
    case save(localID: URL, url: URL)
    case fetchArchivePage(cursor: String?, isFavorite: Bool?)
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
