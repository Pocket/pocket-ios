import Sync
import Foundation


extension SavedItem: Readable {
    var readerURL: URL? {
        item?.resolvedURL ?? item?.givenURL ?? url
    }

    var particleJSON: String? {
        item?.particleJSON
    }

    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(item: self, additionalText: additionalText)
    }
}
