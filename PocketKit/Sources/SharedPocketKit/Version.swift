// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/**
 Helper struct for comparing app versions
 */
public struct Version: Comparable, Codable {
    let major: Int
    let minor: Int
    let patch: Int

    public init(_ versionString: String) {
        let components = versionString.components(separatedBy: ".").compactMap { Int($0) }
        major = components[safe: 0] ?? 0
        minor = components[safe: 1] ?? 0
        patch = components[safe: 2] ?? 0
    }

    public static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }

    public static func == (lhs: Version, rhs: Version) -> Bool {
        return lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch == rhs.patch
    }
}
