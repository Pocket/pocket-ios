// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI


class ReaderSettingsViewController: UIHostingController<ReaderSettingsView> {
    private let onDismiss: () -> Void

    init(settings: ReaderSettings, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: ReaderSettingsView(settings: settings))
    }

    override func viewDidDisappear(_ animated: Bool) {
        if isBeingDismissed {
            onDismiss()
        }
    }

    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
