// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
@preconcurrency import SharedWithYou
import SharedPocketKit

/// SwiftUI version of a `SWAttributionView`
struct SharedWithYouAttributionView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> UIView {
        let attributionView = SWAttributionView()
        attributionView.displayContext = .summary
        return attributionView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        Task { @MainActor in
            do {
                let highlight = try await SWHighlightCenter().highlight(for: url)
                guard let atttributionView = uiView as? SWAttributionView else { return }
                atttributionView.highlight = highlight
            } catch {
                Log.capture(message: "SWH: item cell configuration - unable to retrieve highlight for url: \(url.absoluteString) - Error: \(error)")
            }
        }
    }
}
