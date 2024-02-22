// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedWithYou

/// Shared With You highlights store
final class SharedWithYouStore: NSObject, ObservableObject {
    private let highlightCenter: SWHighlightCenter

    @Published var highlights: [SWHighlight]

    init(highlightCenter: SWHighlightCenter? = nil) {
        self.highlightCenter = highlightCenter ?? SWHighlightCenter()
        self.highlights = self.highlightCenter.highlights
        super.init()
        self.highlightCenter.delegate = self
    }
}

extension SharedWithYouStore: SWHighlightCenterDelegate {
    /// Emits changes in the shared with you list associated with the app
    func highlightCenterHighlightsDidChange(_ highlightCenter: SWHighlightCenter) {
        // if the list is different (either by elements or sort order) replace it
        if highlightCenter.highlights != self.highlights {
            self.highlights = highlightCenter.highlights
        }
    }
}
