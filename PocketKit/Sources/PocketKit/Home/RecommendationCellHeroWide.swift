// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher

class RecommendationCellHeroWide: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        return imageView
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    private let excerptLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.numberOfLines = 4
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    private let publisherLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.adjustsFontForContentSizeCategory = true

        return label
    }()

    private let saveButton: RecommendationSaveButton = {
        let button = RecommendationSaveButton()
        button.accessibilityIdentifier = "save-button"
        return button
    }()

    private let overflowMenuButton: RecommendationButton = {
        let button = RecommendationButton(asset: .overflow)
        button.accessibilityIdentifier = "overflow-button"
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let topLevelStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()

    private let metadataStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()

    private let headlineExcerptStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 14

        return stackView
    }()

    private let publisherButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private let publisherStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        stackView.spacing = 4

        return stackView
    }()

    private let buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.masksToBounds = false
        layer.cornerRadius = Constants.cornerRadius
        layer.shadowColor = UIColor(.ui.border).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6
        layer.backgroundColor = UIColor(.ui.homeCellBackground).cgColor

        headlineExcerptStack.addArrangedSubview(headlineLabel)
        headlineExcerptStack.addArrangedSubview(excerptLabel)

        publisherStack.addArrangedSubview(publisherLabel)
        publisherStack.addArrangedSubview(authorLabel)

        buttonStack.addArrangedSubview(saveButton)
        buttonStack.addArrangedSubview(overflowMenuButton)
        publisherButtonsStack.addArrangedSubview(publisherStack)
        publisherButtonsStack.addArrangedSubview(UIView())
        publisherButtonsStack.addArrangedSubview(buttonStack)

        let metaContainer = UIView()
        metaContainer.addSubview(headlineExcerptStack)
        metaContainer.addSubview(publisherButtonsStack)
        contentView.addSubview(imageView)
        contentView.addSubview(metaContainer)

        metaContainer.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        metaContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.5),

            metaContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            metaContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            metaContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            metaContainer.leadingAnchor.constraint(equalTo: imageView.trailingAnchor),

            headlineExcerptStack.topAnchor.constraint(equalTo: metaContainer.layoutMarginsGuide.topAnchor),
            headlineExcerptStack.leadingAnchor.constraint(equalTo: metaContainer.layoutMarginsGuide.leadingAnchor),
            headlineExcerptStack.trailingAnchor.constraint(equalTo: metaContainer.layoutMarginsGuide.trailingAnchor),

            publisherButtonsStack.topAnchor.constraint(greaterThanOrEqualTo: headlineExcerptStack.bottomAnchor, constant: 12),
            publisherButtonsStack.leadingAnchor.constraint(equalTo: metaContainer.layoutMarginsGuide.leadingAnchor),
            publisherButtonsStack.trailingAnchor.constraint(equalTo: metaContainer.layoutMarginsGuide.trailingAnchor),
            publisherButtonsStack.bottomAnchor.constraint(equalTo: metaContainer.layoutMarginsGuide.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: HomeRecommendationCellHeroWideViewModel) {
        let imageWidth = bounds.width / 2
        let imageSize = CGSize(width: imageWidth, height: bounds.height)
        let processor = ResizingImageProcessor(referenceSize: imageSize, mode: .aspectFill)
            .append(another: CroppingImageProcessor(size: imageSize))

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: model.imageURL,
            options: [
                .callbackQueue(.dispatch(.global(qos: .userInteractive))),
                .backgroundDecode,
                .scaleFactor(UIScreen.main.scale),
                .processor(processor)
            ]
        )

        headlineLabel.attributedText = model.attributedHeadline
        excerptLabel.attributedText = model.attributedExcerpt
        publisherLabel.attributedText = model.attributedPublisher
        authorLabel.attributedText = model.attributedAuthor

        saveButton.mode = model.saveButtonMode
        if let saveAction = UIAction(model.primaryAction) {
            saveButton.addAction(saveAction, for: .primaryActionTriggered)
        }

        let menuActions = model.overflowActions?.compactMap(UIAction.init) ?? []
        overflowMenuButton.menu = UIMenu(children: menuActions)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.shadowPath = UIBezierPath(
            roundedRect: layer.bounds,
            cornerRadius: layer.cornerRadius
        ).cgPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Views get notified of trait collection changes (e.g theme), but layers do not
            // We can dynamically update the base layer color, then, if there was a theme change
            layer.backgroundColor = UIColor(.ui.white1).cgColor
        }
    }
}

extension RecommendationCellHeroWide {
    enum Constants {
        static let cornerRadius: CGFloat = 16
    }
}
