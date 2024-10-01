// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Network

/// SwiftUI version of the `Reader`
struct ReaderView: UIViewControllerRepresentable {
    let route: ReadableRoute

    func makeUIViewController(context: Context) -> UIViewController {
        // TODO: SWIFTUI - add implementation
        if let model = makeReadableViewModel() {
            return ReadableViewController(readable: model, readerSettings: model.readerSettings)
        }
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // TODO: SWIFTUI - add implementation
    }
}

private extension ReaderView {
    func makeReadableViewModel() -> ReadableViewModel? {
        if let savedItemUrlString = route.savedItemUrlString {
            return SavedItemViewModel.fromURL(savedItemUrlString)
        }
        if let syndictedUrlString = route.itemUrlString {
            return RecommendableItemViewModel.fromURL(syndictedUrlString)
        }

        return nil
    }
}
