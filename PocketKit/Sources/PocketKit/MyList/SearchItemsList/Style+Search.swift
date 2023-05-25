// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile

extension Style {
    struct Search {
        let header: Style = Style.header.sansSerif.p4.with(color: .ui.grey4)
        struct Row {
            let `default`: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.black1)
        }
        let row = Row()
    }
    static let search = Search()
}
