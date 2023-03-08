// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// Modified from https://stackoverflow.com/questions/53123171/custom-uirefreshcontrol-with-lottie

import UIKit
import Lottie

public class LottieRefreshControl: UIRefreshControl {
    fileprivate let animationView: LottieAnimationView
    fileprivate var isAnimating = false

    fileprivate let maxPullDistance: CGFloat = 150

    public init(_ pocketAnimation: PocketAnimation, frame: CGRect, primaryAction: UIAction?) {
        animationView = LottieAnimationView(animation: pocketAnimation.animation())
        super.init(frame: frame)
        setupView()
        setupLayout()
        if let primaryAction = primaryAction {
            self.addAction(primaryAction, for: .primaryActionTriggered)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateProgress(with offsetY: CGFloat) {
        guard !isAnimating else { return }
        let progress = min(abs(offsetY / maxPullDistance), 1)
        animationView.currentProgress = progress
    }

    override public func beginRefreshing() {
        super.beginRefreshing()
        isAnimating = true
        animationView.currentProgress = 0
        animationView.play()
    }

    override public func endRefreshing() {
        super.endRefreshing()
        animationView.stop()
        isAnimating = false
    }
}

private extension LottieRefreshControl {
    func setupView() {
        // hide default indicator view
        tintColor = .clear
        animationView.loopMode = .loop
        addSubview(animationView)

        addTarget(self, action: #selector(beginRefreshing), for: .valueChanged)
    }

    func setupLayout() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: centerYAnchor),
            animationView.widthAnchor.constraint(equalToConstant: 50),
            animationView.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
}
