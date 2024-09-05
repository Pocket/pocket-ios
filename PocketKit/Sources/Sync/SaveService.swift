// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum SaveServiceStatus {
    case existingItem(CDSavedItem)
    case newItem(CDSavedItem)
    case taggedItem(CDSavedItem)

    var savedItem: CDSavedItem {
        switch self {
        case .existingItem(let savedItem), .newItem(let savedItem), .taggedItem(let savedItem):
            return savedItem
        }
    }
}

public protocol SaveService {
    func save(url: String) -> SaveServiceStatus
    func retrieveTags(excluding tags: [String]) -> [CDTag]?
    func filterTags(with text: String, excluding tags: [String]) -> [CDTag]?
    func addTags(savedItem: CDSavedItem, tags: [String]) -> SaveServiceStatus
}
