// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import PKTListen
import SharedPocketKit
import Down

class ListenConfiguration: NSObject {
    let title: String
    private let savedItems: [SavedItem]?
    private let featureFlagService: FeatureFlagServiceProtocol

    init(title: String, savedItems: [SavedItem]?, featureFlagService: FeatureFlagServiceProtocol) {
        self.title = title
        self.savedItems = savedItems
        self.featureFlagService = featureFlagService
    }

    func toAppConfiguration() -> PKTListenAppConfiguration {
        let source = ListenSource(savedItems: savedItems, featureFlagService: featureFlagService)
        let config = PKTListenAppConfiguration(source: source)
        config.playerDelegate = source
        return config
    }
}

private class ListenSource: PKTListenDataSource<PKTListDiffable>, PKTListenPlayerDelegate {
    private var savedItems: [SavedItem]!
    private var featureFlagService: FeatureFlagServiceProtocol!

    convenience init(savedItems: [SavedItem]?, featureFlagService: FeatureFlagServiceProtocol) {
        let config = PKTListenAppKusariConfiguration()

        let listenItems: [PKTKusari<PKTListenItem>] = savedItems?
            .compactMap { $0 }
            .filter { $0.isEligibleForListen }
            .compactMap { PKTListenKusariCreate($0.albumID!, PKTListenQueueSectionType.item.rawValue, $0, config) }
        ?? []

        defer {
            DispatchQueue.global(qos: .background).async {
                // Warm up the first 6 images
                listenItems.prefix(6).forEach({ listenItem in
                    listenItem.warmImage()
                })
            }
        }

        self.init(context: ["index": NSNumber(value: 0)]) { source, context, complete in
            source.hasMore = false
            Log.debug("Loaded Listen with \(listenItems.count) articles")
            complete(nil, ["index": NSNumber(value: listenItems.count)], listenItems)
        }

        self.savedItems = savedItems
        self.featureFlagService = featureFlagService
    }

    // MARK: PKTListenPlayerDelegate

    func textUnits(for kusari: PKTKusari<PKTListenItem>) -> [PKTTextUnit] {
        // When returning the text components for offline TTS,
        // fetch the saved item with the given URL of the item staged for playing, ensuring it has an article
        guard let givenURL = kusari.album?.givenURL,
              let savedItem = savedItems?.first(where: { $0.givenURL == givenURL }),
              let article = savedItem.item?.article
        else {
            return []
        }

        // For offline TTS, filter out only components that contain text "blocks", returning the appropriate types
        return article.components.compactMap { c in
            switch c {
            case .blockquote(let component): return component.content
            case .bulletedList(let component): return string(from: component)
            case .codeBlock(let component): return component.text
            case .divider: return nil
            case .heading(let component): return component.content
            case .image(let component): return string(from: component)
            case .numberedList(let component): return string(from: component)
            case .table: return nil
            case .text(let textComponent): return textComponent.content
            case .unsupported: return nil
            case .video: return nil
            }
        }
        .filter { $0.isEmpty == false }
        .compactMap {
            // The built-in NSAttributedString(markdown:) initializer would strangely strip
            // out numbers from bulleted lists; the Down parser used for styling article components
            // tends to do a better job keeping the desired "structure" of Markdown strings.
            try? Down(markdownString: $0).toAttributedString()
        }
        .map { ListenTextUnit(attributedString: $0) }
    }

    func isKusariAvailable(forOfflineTTS kusari: PKTKusari<PKTListenItem>) -> Bool {
        return textUnits(for: kusari).isEmpty == false
    }

    func isOnlinePlayerAvailable() -> Bool {
        return featureFlagService.isAssigned(flag: .disableOnlineListen) == false
    }

    // MARK: Private

    private func string(from component: BulletedListComponent) -> String? {
        // Return a newline-separated string of all rows, with bullets added.
        // Adding a comma before separating by newline also introduces a pause in the speach, to
        // provide better separation between the rows in the list during speech synthesis.
        return component.rows.map { $0.content }.joined(separator: ",\n")
    }

    private func string(from component: NumberedListComponent) -> String? {
        // Return a newline-separated string of all rows, with line numbers added.
        // Line numbers are determined by a row's index, which is 0-based (so add 1).
        // Adding a comma before separating by newline also introduces a pause in the speach, to
        // provide better separation between the rows in the list during speech synthesis.
        return component.rows.map { "\($0.index + 1). \($0.content)" }.joined(separator: ",\n")
    }

    private func string(from component: ImageComponent) -> String? {
        guard let caption = component.caption, caption.isEmpty == false else { return nil }
        return "Image: \(caption)"
    }
}

private class ListenTextUnit: NSObject, PKTTextUnit {
    var type: PKTTagMatchType = .text

    var attributedStringValue: NSAttributedString?
    var stringValue: String?

    var tagValue: String?

    init(attributedString: NSAttributedString) {
        self.attributedStringValue = attributedString
        self.stringValue = attributedString.string
    }
}
