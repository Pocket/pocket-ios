// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

@MainActor
public struct PocketAppDependencyContainer {
    public init() {}
    public func makeRootView() -> some View {
        let model = makeRootViewModel()

        return RootView(model: model)
            .onOpenURL { url in
                model.handleUrl(url)
            }
    }

    private func makeRootViewModel() -> RootViewModel {
        RootViewModel()
    }
}
