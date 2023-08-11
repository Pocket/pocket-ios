// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Style {
    struct DeleteAccountView {
        public let header: Style = Style.header.sansSerif.h2.with(color: .ui.black1)
        public let warning: Style = Style.header.sansSerif.p2.with(color: .ui.black1).with(weight: .bold)
        public let body: Style = Style.header.sansSerif.p3.with(color: .ui.black1)
    }

    static let deleteAccountView = DeleteAccountView()
}
