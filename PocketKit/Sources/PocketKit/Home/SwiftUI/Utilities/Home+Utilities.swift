// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync

/// Current layout width
enum LayoutWidth {
    case compact
    case wide
    case extraWide

    var isRegular: Bool {
        switch self {
        case .compact: return false
        case .wide, .extraWide: return true
        }
    }

    var isCompact: Bool {
        switch self {
        case .compact: return true
        case .wide, .extraWide: return false
        }
    }
    /// Preferred number of columns in a grid view
    var preferredNumberOfColumns: Int {
        switch self {
        case .compact:
            return 1
        case .wide:
            return 2
        case .extraWide:
            return 3
        }
    }
}

/// Array extension that divides an array into chunks of a predefined size.
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

/// Convenience environment valus
extension EnvironmentValues {
    /// Store the carousel width based on the current `Geometry`
    @Entry var carouselWidth: CGFloat = 300

    /// The layout width to adopt in views that adapt to it
    @Entry var layoutWidth: LayoutWidth = .compact
}

/// Convenience properties for Item title
extension Item {
    public var bestTitle: String {
        validTitle(syndicatedArticle?.title) ??
        validTitle(title) ??
        validTitle(recommendation?.title) ??
        givenURL
    }

    private func validTitle(_ title: String?) -> String? {
        guard let title, !title.isEmpty else {
            return nil
        }
        return title
    }
}
