// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync

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

    /// True if the iPad/w regular size should be used
    @Entry var useWideLayout: Bool = false
}

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
