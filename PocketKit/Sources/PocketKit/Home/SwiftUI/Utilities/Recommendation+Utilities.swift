// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync

/// An identifiable type containing a row of recommendations to be used in a `GridRow`
struct RecommendationsRow: Identifiable {
    let id = UUID()
    let row: [Recommendation]
}

/// Array extension that divides an array into chunks of a predefined size.
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
