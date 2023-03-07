// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// Modified from https://designcode.io/swiftui-handbook-lottie-animation

import Foundation
import UIKit
import Lottie
import SwiftUI

public struct LottieView: UIViewRepresentable {
    public enum PocketAnimations {
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
    }

    public init(_ name: PocketAnimations, loopMode: LottieLoopMode = .loop) {
        self.name = name
        self.loopMode = loopMode
    }

    var name: PocketAnimations
    var loopMode: LottieLoopMode = .loop

    public func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name.name(), bundle: .module, subdirectory: "Assets")
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}
