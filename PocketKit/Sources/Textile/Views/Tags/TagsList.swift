// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public protocol TagsList {
    func arrangeTags(with tags: [String]) -> [TagType]
}

public extension TagsList {
    func arrangeTags(with tags: [String]) -> [TagType] {
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
}
