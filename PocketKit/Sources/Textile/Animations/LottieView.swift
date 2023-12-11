// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// Modified from https://designcode.io/swiftui-handbook-lottie-animation

import Foundation
import UIKit
import Lottie
import SwiftUI

// TODO: As of Lottie 4.3.0 Lottie is SwiftUI Native and we can remove this wrapper.
public struct LottieView: UIViewRepresentable {
    public init(_ pocketAnimation: PocketAnimation, loopMode: LottieLoopMode = .loop) {
        self.pocketAnimation = pocketAnimation
        self.loopMode = loopMode
    }

    var pocketAnimation: PocketAnimation
    var loopMode: LottieLoopMode = .loop

    public func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        let animationView = LottieAnimationView()
        let animation = pocketAnimation.animation()
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
