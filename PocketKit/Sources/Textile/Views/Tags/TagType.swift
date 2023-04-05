// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public enum TagType: Hashable {
    case notTagged
    case tag(String)

    public var name: String {
        switch self {
        case .notTagged:
            return "not tagged"
        case .tag(let name):
            return name
        }
    }
}

/// Arranges the list of tags for a user in both the Add Tags / Edit Tags view
/// - Parameter tags: list of users tag names
/// - Returns: converts users tags to display a list of `TagType`
public func arrangeTags(with tags: [String]) -> [TagType] {
    var allTags: [String] = []
    let fetchedTags = tags.reversed()
    if fetchedTags.count > 3 {
        let topRecentTags = Array(fetchedTags)[..<3]
        let sortedTags = Array(fetchedTags)[3...].sorted()
        allTags.append(contentsOf: topRecentTags)
        allTags.append(contentsOf: sortedTags)
    } else {
        allTags.append(contentsOf: fetchedTags)
    }
    return allTags.compactMap { TagType.tag($0) }
}
