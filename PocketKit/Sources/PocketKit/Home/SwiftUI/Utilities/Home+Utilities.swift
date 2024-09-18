// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync

/// An identifiable type containing a row of `Item`s to be used in a `GridRow`
struct ItemsRow: Identifiable {
    let id = UUID()
    let row: [Item]
}

/// Array extension that divides an array into chunks of a predefined size.
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

/// Environment value to store the carousel width based on the current `Geometry`
extension EnvironmentValues {
    @Entry var carouselWidth: CGFloat = 300
}

extension Item {
    public var bestTitle: String {
        validTitle(recommendation?.title) ??
        validTitle(syndicatedArticle?.title) ??
        validTitle(title) ??
        givenURL
    }

    private func validTitle(_ title: String?) -> String? {
        guard let title, !title.isEmpty else {
            return nil
        }
        return title
    }
}
