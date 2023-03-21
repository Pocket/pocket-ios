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
