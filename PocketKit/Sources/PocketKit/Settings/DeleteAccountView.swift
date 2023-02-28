// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SwiftUI
import Textile

struct DeleteAccountView: View {
    @ObservedObject
    var model: AccountViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Coming Soon")
        }
        .navigationBarTitle(L10n.Settings.AccountManagement.deleteYourAccount, displayMode: .large)
        .accessibilityIdentifier("delete-account")
    }
}
