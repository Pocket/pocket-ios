// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/**
 Helper struct for comparing app versions
 */
public struct Version: Comparable, Codable {
    var _version: String

    public init(_ versionString: String) {
        _version = versionString
    }

    public static func < (lhs: Version, rhs: Version) -> Bool {
        let result = lhs._version.compare(rhs._version, options: .numeric)
        if result == .orderedAscending {
            return true
        } else if result == .orderedDescending {
            return false
        }
        return false
    }

    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs._version.compare(rhs._version, options: .numeric) == .orderedSame
    }
}
