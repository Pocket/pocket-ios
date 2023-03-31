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
