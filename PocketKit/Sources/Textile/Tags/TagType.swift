// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public enum TagType: Hashable, Comparable {
    case notTagged
    case recent(String)
    case tag(String)

    public var name: String {
        switch self {
        case .notTagged:
            return "not tagged"
        case .tag(let name), .recent(let name):
            return name
        }
    }

    public static func < (lhs: TagType, rhs: TagType) -> Bool {
        return lhs.name < rhs.name
    }

    public static func > (lhs: TagType, rhs: TagType) -> Bool {
        return lhs.name > rhs.name
    }

    public static func == (lhs: TagType, rhs: TagType) -> Bool {
        return lhs.name == rhs.name
    }
}
