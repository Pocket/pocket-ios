// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Textile


private extension Style {
    static let sectionHeader: Style = .header.sansSerif.h7
}

struct SlateHeaderPresenter {
    private let slate: Slate

    init(slate: Slate) {
        self.slate = slate
    }

    var attributedHeaderText: NSAttributedString {
        NSAttributedString(slate.name ?? "", style: .sectionHeader)
    }
}
