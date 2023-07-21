// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Lottie

public class EndOfFeedAnimationView: UIView {
    private lazy var textLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    public var attributedText: NSAttributedString? {
        get { textLabel.attributedText }
        set { textLabel.attributedText = newValue }
    }

    private lazy var animationView: LottieAnimationView = {
        let view = LottieAnimationView(animation: nil, configuration: LottieConfiguration(renderingEngine: .automatic))
        return view
    }()

    public var isAnimating: Bool {
        get { animationView.isAnimationPlaying }
        set {
            if newValue == true {
                animationView.play { _ in
                    self.didFinishPreviousAnimation = true
                }
            } else {
                animationView.stop()
                animationView.currentTime = 0
                didFinishPreviousAnimation = false
            }
        }
    }

    private(set) public var didFinishPreviousAnimation: Bool = false

    override public init(frame: CGRect) {
        defer { loadAnimation() }
        super.init(frame: frame)

        textLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        textLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        animationView.setContentCompressionResistancePriority(.required, for: .horizontal)
        animationView.setContentCompressionResistancePriority(.required, for: .vertical)

        let stackView = UIStackView(arrangedSubviews: [textLabel, animationView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.alignment = .center

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, constant: -16),
            stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -16)
        ])

        updatePageColors()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updatePageColors()
    }

    private func updatePageColors() {
        let colorValueProvider: ColorValueProvider?
        switch traitCollection.userInterfaceStyle {
        case .light:
            colorValueProvider = ColorValueProvider(LottieColor(.ui.black))
        case .dark:
            colorValueProvider = ColorValueProvider(LottieColor(.ui.white))
        case .unspecified:
            colorValueProvider = nil
        @unknown default:
            colorValueProvider = nil
        }

        let keypath = AnimationKeypath(keys: ["Book Animation - DYNAMIC", "PAGE_COLOR", "Group 1", "Stroke 1", "Color"])
        if let colorValueProvider = colorValueProvider {
            animationView.setValueProvider(colorValueProvider, keypath: keypath)
        } else {
            // Resets the value providers since there is no explicit "remove" API
            animationView.animation = animationView.animation
        }
    }

    private func loadAnimation() {
        // Load the end-of-feed animation on a background thread, and update the animation view once available.
        // This should mitigate some main thread file IO messages in Sentry.
        // Details: https://github.com/airbnb/lottie-ios/issues/872#issuecomment-1176773074
        DispatchQueue.global(qos: .userInitiated).async {
            let animation = PocketAnimation.endOfFeed.animation()
            DispatchQueue.main.async { [weak self] in
                self?.animationView.animation = animation
            }
        }
    }
}

private extension LottieColor {
    init(_ colorAsset: ColorAsset) {
        let color = UIColor(colorAsset)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: nil)
        self.init(r: r, g: g, b: b, a: 1)
    }
}
