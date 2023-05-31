// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

import Lottie

public enum PocketAnimation {
    case endOfFeed
    case loading

    func name() -> String {
        switch self {
        case .endOfFeed:
            return "end-of-feed.json"
        case .loading:
            return "loading.json"
        }
    }

    func animation() -> LottieAnimation? {
        LottieAnimation.named(self.name(), bundle: .module, subdirectory: "Assets")
    }
}
