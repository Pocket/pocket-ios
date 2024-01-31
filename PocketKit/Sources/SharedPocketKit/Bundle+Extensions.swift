// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension Bundle {
    public var appName: String { getInfo("CFBundleName") ?? "Unknown" }
    public var displayName: String { getInfo("CFBundleDisplayName") ?? "Unknown"  }
    public var language: String { getInfo("CFBundleDevelopmentRegion") ?? "Unknown"  }
    public var identifier: String { getInfo("CFBundleIdentifier") ?? "Unknown"  }
    public var copyright: String { (getInfo("NSHumanReadableCopyright") ?? "Unknown").replacingOccurrences(of: "\\\\n", with: "\n") }

    public var appBuild: String { getInfo("CFBundleVersion") ?? "1"  }
    public var appVersion: Version { Version(getInfo("CFBundleShortVersionString") ?? "1.0.0") }

    fileprivate func getInfo(_ str: String) -> String? { infoDictionary?[str] as? String }
}
