// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

// MARK: max thumbnail width
private struct MaxThumbnailWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var maxThumbnailWidth: CGFloat {
        get { self[MaxThumbnailWidthKey.self] }
        set { self[MaxThumbnailWidthKey.self] = newValue }
    }
}

extension View {
    func maxThumbnailWidth(_ value: CGFloat) -> some View {
        environment(\.maxThumbnailWidth, value)
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
