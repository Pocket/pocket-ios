// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

// MARK: thumbnail width
private struct ThumbnailWidthKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var thumbnailWidth: CGFloat {
        get { self[ThumbnailWidthKey.self] }
        set { self[ThumbnailWidthKey.self] = newValue }
    }
}

extension View {
    func thumbnailWidth(_ value: CGFloat) -> some View {
        environment(\.thumbnailWidth, value)
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

// MARK: maximum number of items by widget family
private struct MaxNumberOfItemsKey: EnvironmentKey {
    static let defaultValue: Int = 0
}

extension EnvironmentValues {
    var maxNumberOfItems: Int {
        get { self[MaxNumberOfItemsKey.self] }
        set { self[MaxNumberOfItemsKey.self] = newValue }
    }
}

extension View {
    func maxNumberOfItems(_ value: Int) -> some View {
        environment(\.maxNumberOfItems, value)
    }
}

// MARK: title color
private struct TitleColorKey: EnvironmentKey {
    static let defaultValue: ColorAsset = .ui.coral2
}

extension EnvironmentValues {
    var titleColor: ColorAsset {
        get { self[TitleColorKey.self] }
        set { self[TitleColorKey.self] = newValue }
    }
}

extension View {
    func titleColor(_ value: ColorAsset) -> some View {
        environment(\.titleColor, value)
    }
}
