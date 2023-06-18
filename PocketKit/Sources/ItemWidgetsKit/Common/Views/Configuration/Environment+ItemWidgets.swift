// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

// MARK: max thumbnail size
private struct MaxThumbnailSizeKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var maxThumbnailSize: CGFloat {
        get { self[MaxThumbnailSizeKey.self] }
        set { self[MaxThumbnailSizeKey.self] = newValue }
    }
}

extension View {
    func maxThumbnailSize(_ value: CGFloat) -> some View {
        environment(\.maxThumbnailSize, value)
    }
}

// MARK: very large accessibility categories (XXL and larger)
private struct HasVeryLargeFontsKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var hasVeryLargeFonts: Bool {
        get { self[HasVeryLargeFontsKey.self] }
        set { self[HasVeryLargeFontsKey.self] = newValue }
    }
}

extension View {
    func hasVeryLargeFonts(_ value: Bool) -> some View {
        environment(\.hasVeryLargeFonts, value)
    }
}
