// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreData
import CoreSpotlight

/// Delegate to listen to callbacks from CoreData when something needs to be indexed
class CoreDataSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
    override func domainIdentifier() -> String {
        return "com.mozilla.pocket"
    }

    override func indexName() -> String? {
        return "pocket-index"
    }

    override func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        if let savedItem = object as? SavedItem {
            return csSearchableItemAttributeSet(for: savedItem)
        }

        return nil
    }

    /// Helper function to turn a SavedItem into a CSSearchableItemAttributeSet
    /// - Parameter savedItem: The saved item to search
    /// - Returns: The CoreSpotlight result
    private func csSearchableItemAttributeSet(for savedItem: SavedItem) -> CSSearchableItemAttributeSet {
        let identifier = savedItem.remoteID
        let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
        attributeSet.identifier = identifier
        attributeSet.displayName = savedItem.item?.title
        attributeSet.publishers = (savedItem.item?.authors?.array as? [CDAuthor] ?? []).compactMap { $0.name }
        attributeSet.thumbnailURL = savedItem.item?.topImageURL // TODO: Image cache url..
        attributeSet.contentURL = URL(string: savedItem.url)
        attributeSet.contentDescription = savedItem.item?.excerpt
        attributeSet.title = savedItem.item?.title
        attributeSet.contentCreationDate = savedItem.item?.datePublished

        return attributeSet
    }
}
