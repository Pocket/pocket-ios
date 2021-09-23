// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct ImageAsset {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

extension ImageAsset {
    public static let save = ImageAsset("save")
    public static let horizontalOverflow = ImageAsset("horizontalOverflow")
    public static let verticalOverflow = ImageAsset("verticalOverflow")
}
