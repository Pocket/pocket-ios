// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Textile

enum InfoViewStyle {
    case `default`
    case error
}

class InfoView: UIView {
    private let capsuleView = CapsuleView()

    private let detailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [capsuleView, detailTextLabel])
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()

    private var attributedText: NSAttributedString? {
        get { capsuleView.attributedText }
        set { capsuleView.attributedText = newValue }
    }

    private var attributedDetailText: NSAttributedString? {
        get { detailTextLabel.attributedText }
        set { detailTextLabel.attributedText = newValue }
    }

    private var style: InfoViewStyle = .default {
        didSet { capsuleView.style = style }
    }

    var model: Model? {
        didSet {
            style = model?.style ?? .default
            attributedText = model?.attributedText ?? nil
            attributedDetailText = model?.attributedDetailText ?? nil
        }
    }

    init() {
        super.init(frame: .zero)

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        accessibilityIdentifier = "save-extension-info-view"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class CapsuleView: UIView {
    private let imageView = UIImageView()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    var attributedText: NSAttributedString? {
        get { textLabel.attributedText }
        set { textLabel.attributedText = newValue }
    }

    var style: InfoViewStyle = .default {
        didSet { updateStyle() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        updateStyle()

        addSubview(imageView)
        addSubview(textLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),

            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 28),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),

            heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor, constant: 10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2
    }

    private func updateStyle() {
        switch style {
        case .default:
            backgroundColor = UIColor(.ui.teal6)
            imageView.image = UIImage(asset: .circleChecked)
        case .error:
            backgroundColor = UIColor(.ui.coral5)
            imageView.image = UIImage(asset: .error)
        }
    }
}

extension InfoView {
    struct Model {
        let style: InfoViewStyle
        let attributedText: NSAttributedString
        let attributedDetailText: NSAttributedString?
    }
}
