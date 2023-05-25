// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

class ReaderSettingsViewController: OnDismissHostingController<ReaderSettingsView> {
    init(settings: ReaderSettings, onDismiss: @escaping () -> Void) {
        super.init(
            rootView: ReaderSettingsView(settings: settings),
            onDismiss: onDismiss
        )
    }

    @MainActor
    @objc
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
