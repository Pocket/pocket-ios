// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Textile

extension Style {
    static let listCellTitle: Style = .header.sansSerif.h8
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
    static let listCellPendingTitle: Style = listCellTitle.with(color: .ui.grey5)

    static let listCellDetail: Style = .header.sansSerif.p4
        .with(color: .ui.grey4)
        .with { paragraph in
            paragraph
                .with(lineSpacing: 4)
                .with(lineBreakMode: .byTruncatingTail)
        }
    static let listCellPendingDetail: Style = .listCellDetail.with(color: .ui.grey5)
    static let listCellTag: Style = .header.sansSerif.p5.with(color: .ui.grey4).with(weight: .medium).with { paragraph in
        paragraph
            .with(lineBreakMode: .byTruncatingTail)
    }
    static let listCellTagCount: Style = .header.sansSerif.h8.with(color: .ui.grey4)
}
