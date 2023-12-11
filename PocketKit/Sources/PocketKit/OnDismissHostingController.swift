// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

class OnDismissHostingController<T: View>: UIHostingController<T> {
    private let onDismiss: () -> Void

    init(rootView: T, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        if isBeingDismissed {
            onDismiss()
        }
        super.viewDidDisappear(animated)
    }

    @MainActor
    @objc
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
