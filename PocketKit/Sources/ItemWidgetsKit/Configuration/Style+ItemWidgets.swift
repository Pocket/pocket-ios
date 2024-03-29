// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile

extension Style {
    static let domain: Style = .header.sansSerif.p6.with(color: .ui.grey8)
    static let emptyWidgetMessage: Style = .header.sansSerif.p2.with(color: .ui.grey8).with(alignment: .center)

    static func widgetHeader(_ color: ColorAsset) -> Style {
        .header.sansSerif.h8.with(color: color)
    }
}
