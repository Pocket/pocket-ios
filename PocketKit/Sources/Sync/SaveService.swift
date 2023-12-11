// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum SaveServiceStatus {
    case existingItem(SavedItem)
    case newItem(SavedItem)
    case taggedItem(SavedItem)

    var savedItem: SavedItem {
        switch self {
        case .existingItem(let savedItem), .newItem(let savedItem), .taggedItem(let savedItem):
            return savedItem
        }
    }
}

public protocol SaveService {
    func save(url: String) -> SaveServiceStatus
    func retrieveTags(excluding tags: [String]) -> [Tag]?
    func filterTags(with text: String, excluding tags: [String]) -> [Tag]?
    func addTags(savedItem: SavedItem, tags: [String]) -> SaveServiceStatus
}
