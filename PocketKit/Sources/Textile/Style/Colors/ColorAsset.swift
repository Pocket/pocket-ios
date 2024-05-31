// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct ColorAsset: Sendable {
    let _name: String

    init(name: String) {
        self._name = name
    }

    static func ui(_ name: String) -> Self {
        Self(name: "UI/\(name)")
    }

    static func branding(_ name: String) -> Self {
        Self(name: "Branding/\(name)")
    }

    static func listen(_ name: String) -> Self {
        Self(name: "Listen/\(name)")
    }
}
