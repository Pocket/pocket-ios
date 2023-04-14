// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization

public enum TagType: Hashable {
    case notTagged
    case recent(String)
    case tag(String)

    public var name: String {
        switch self {
        case .notTagged:
            return Localization.Tags.notTagged
        case .tag(let name), .recent(let name):
            return name
        }
    }
}

/// Arranges the list of tags for a user in both the Add Tags / Edit Tags view
/// - Parameter tags: list of users tag names
/// - Returns: converts users tags to display a list of `TagType`
public func arrangeTags(with tags: [String]) -> [TagType] {
    return Array(Set(tags)).sorted().compactMap { TagType.tag($0) }
}
