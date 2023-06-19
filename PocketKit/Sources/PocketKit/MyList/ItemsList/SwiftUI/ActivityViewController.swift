// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct ShareSheetView: UIViewControllerRepresentable {
    let activity: PocketActivity

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activity: activity)
        controller.sheetPresentationController?.detents = [.medium()]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}
