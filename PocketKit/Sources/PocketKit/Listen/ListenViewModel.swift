// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import PKTListen
import SharedPocketKit

class ListenConfiguration: NSObject, PKTListenOfflineTTSDelegate {
    let title: String
    private let savedItems: [SavedItem]?

    init(title: String, savedItems: [SavedItem]?) {
        self.title = title
        self.savedItems = savedItems
    }

    func toAppConfiguration() -> PKTListenAppConfiguration {
        let config = PKTListenAppConfiguration(source: createSource())
        config.offlineTTSDelegate = self
        return config
    }

    private func createSource() -> ListenSource {
        return ListenSource.source(savedItems: savedItems)
    }

    func textUnits(for kusari: PKTKusari<PKTListenItem>) -> [PKTTextUnit] {
        // When returning the text components for offline TTS,
        // fetch the saved item with the given URL of the item staged for playing, ensuring it has an article
        guard let givenURL = kusari.album?.givenURL,
              let savedItem = savedItems?.first(where: { $0.givenURL == givenURL }),
              let article = savedItem.item?.article
        else {
            return []
        }

        // For offline TTS, filter out only the text components, returning the appropriate types
        return article.components.compactMap { c in
            switch c {
            // Utilize the NSAttributedString(markdown:) initializer to "strip out" the characters used for styling
            case .text(let textComponent): return try? NSAttributedString(markdown: textComponent.content).string
            default: return nil
            }
        }.map { ListenTextUnit(stringValue: $0) }
    }
}

class ListenSource: PKTListenDataSource<PKTListDiffable> {
    static func source(savedItems: [SavedItem]?) -> ListenSource {
        let config = PKTListenAppKusariConfiguration()

        let listenItems: [PKTKusari<PKTListenItem>] = savedItems?
            .compactMap { $0 }
            .filter { $0.isEligibleForListen }
            .compactMap { PKTListenKusariCreate($0.albumID!, PKTListenQueueSectionType.item.rawValue, $0, config) }
        ?? []

        DispatchQueue.global(qos: .background).async {
            // Warm up the first 6 images
            listenItems.prefix(6).forEach({ listenItem in
                listenItem.warmImage()
            })
        }

        return ListenSource(context: ["index": NSNumber(value: 0)]) { source, context, complete in
            source.hasMore = false
            Log.debug("Loaded Listen with \(listenItems.count) articles")
            complete(nil, ["index": NSNumber(value: listenItems.count)], listenItems)
        }
    }
}

private class ListenTextUnit: NSObject, PKTTextUnit {
    var type: PKTTagMatchType = .text

    var stringValue: String?

    var tagValue: String?

    init(stringValue: String) {
        self.stringValue = stringValue
    }
}
