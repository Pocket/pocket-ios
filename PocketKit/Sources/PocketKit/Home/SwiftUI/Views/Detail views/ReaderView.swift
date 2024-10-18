// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Network

/// SwiftUI version of the `Reader`
struct ReaderView: UIViewControllerRepresentable {
    let route: ReadableRoute

    class Coordinator {
        var parentObserver: NSKeyValueObservation?
    }

    func makeUIViewController(context: Context) -> UIViewController {
        if let model = makeReadableViewModel() {
            let viewController = ReadableHostViewController(readableViewModel: model)
            context.coordinator.parentObserver = viewController.observe(\.parent?.navigationItem.rightBarButtonItems, changeHandler: { viewController, _ in
                Task {
                    await update(viewController: viewController)
                }
            })
            return viewController
        }
        return UIViewController()
    }

    @MainActor
    private func update(viewController: UIViewController) -> UIViewController {
        viewController.parent?.title = viewController.title
        viewController.parent?.navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Self.Coordinator { Coordinator() }
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
