// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile
import SharedPocketKit

class HomeCarouselView: UIView {
    private let collectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxCollectionLines
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "collection-label"
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxTitleLines
        label.adjustsFontForContentSizeCategory = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let domainLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxDetailLines
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let timeToReadLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxDetailLines
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(.ui.grey6)
        imageView.contentMode = .center
        return imageView
    }()

    private let favoriteButton: UIButton = {
        let button = HomeCellActionButton(asset: .favorite)
        button.accessibilityIdentifier = "favorite"
        return button
    }()

    let saveButton: ItemCellSaveButton = {
        let button = ItemCellSaveButton()
        button.accessibilityIdentifier = "save-button"
        return button
    }()

    private let overflowButton: UIButton = {
        let button = HomeCellActionButton(asset: .overflow)
        button.accessibilityIdentifier = "overflow-button"
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = Constants.stackSpacing
        stack.axis = .vertical
        return stack
    }()

    private let mainContentStack: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .top
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.axis = .horizontal
        return stack
    }()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .equalSpacing
        stack.alignment = .bottom
        stack.axis = .horizontal
        return stack
    }()

    private let subtitleStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.spacing = 0
        return stack
    }()

    private var thumbnailWidthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        activateConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboards are not welcome here")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }
}

// MARK: configuration
extension HomeCarouselView {
    func configure(with configuration: HomeCarouselCellConfiguration) {
        titleLabel.attributedText = configuration.attributedTitle
        domainLabel.attributedText = configuration.attributedDomain
        timeToReadLabel.attributedText = configuration.attributedTimeToRead

        if let attributedCollection = configuration.attributedCollection {
            collectionLabel.isHidden = false
            collectionLabel.attributedText = attributedCollection
        } else {
            collectionLabel.isHidden = true
        }

        if configuration.attributedTimeToRead.string.isEmpty {
            timeToReadLabel.isHidden = true
            subtitleStack.setCustomSpacing(0, after: timeToReadLabel)
            subtitleStack.setCustomSpacing(Constants.layoutMargins.bottom, after: domainLabel)
        } else {
            timeToReadLabel.isHidden = false
            subtitleStack.setCustomSpacing(Constants.stackSpacing, after: domainLabel)
            subtitleStack.setCustomSpacing(Constants.layoutMargins.bottom, after: timeToReadLabel)
        }

        favoriteButton.accessibilityLabel = configuration.favoriteAction?.title
        favoriteButton.accessibilityIdentifier = configuration.favoriteAction?.accessibilityIdentifier
        favoriteButton.configuration?.image = configuration.favoriteAction?.image?.resized(to: Constants.actionButtonImageSize)

        if let favoriteAction = UIAction(configuration.favoriteAction) {
            favoriteButton.addAction(favoriteAction, for: .primaryActionTriggered)
        }

        if let mode = configuration.saveButtonMode {
            saveButton.isHidden = false
            saveButton.mode = mode
        } else {
            saveButton.isHidden = true
        }

        if let saveAction = UIAction(configuration.saveAction) {
            saveButton.addAction(saveAction, for: .primaryActionTriggered)
        }

        let menuActions = configuration.overflowActions?.compactMap(UIAction.init) ?? []
        overflowButton.menu = UIMenu(children: menuActions)

        thumbnailView.image = nil
        guard let thumbnailURL = configuration.thumbnailURL else {
            thumbnailWidthConstraint.constant = 0
            return
        }

        thumbnailWidthConstraint.constant = StyleConstants.thumbnailSize.width
        thumbnailView.kf.indicatorType = .activity
        thumbnailView.kf.setImage(
            with: thumbnailURL,
            options: [
                .callbackQueue(.dispatch(.global(qos: .userInteractive))),
                .backgroundDecode,
                .scaleFactor(UIScreen.main.scale),
                .processor(
                    ResizingImageProcessor(
                        referenceSize: StyleConstants.thumbnailSize,
                        mode: .aspectFill
                    ).append(
                        another: CroppingImageProcessor(
                            size: StyleConstants.thumbnailSize
                        )
                    )
                )
            ]
        )
    }
}

// MARK: private helpers
private extension HomeCarouselView {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let maxTitleLines = 3
        static let maxDetailLines = 2
        static let maxCollectionLines = 1
        static let actionButtonImageSize = CGSize(width: 20, height: 20)
        static let layoutMargins = UIEdgeInsets(top: Margins.normal.rawValue, left: Margins.normal.rawValue, bottom: Margins.normal.rawValue, right: Margins.normal.rawValue)
        static let stackSpacing: CGFloat = 4
    }

    func activateConstraints() {
        addSubview(mainContentStack)
        addSubview(bottomStack)
        layoutMargins = Constants.layoutMargins

        mainContentStack.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        thumbnailWidthConstraint = thumbnailView.widthAnchor.constraint(
            equalToConstant: StyleConstants.thumbnailSize.width
        ).with(priority: .required)

        NSLayoutConstraint.activate([
            mainContentStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            mainContentStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainContentStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

            thumbnailView.heightAnchor.constraint(equalToConstant: StyleConstants.thumbnailSize.height).with(priority: .required),
            thumbnailWidthConstraint!,

            bottomStack.leadingAnchor.constraint(equalTo: mainContentStack.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: mainContentStack.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: bottomAnchor).with(priority: .required)
        ])

        [UIView(), domainLabel, timeToReadLabel, UIView()].forEach(subtitleStack.addArrangedSubview)
        [favoriteButton, saveButton, overflowButton].forEach(buttonStack.addArrangedSubview)
        [collectionLabel, titleLabel].forEach(textStack.addArrangedSubview)
        [textStack, thumbnailView].forEach(mainContentStack.addArrangedSubview)
        [subtitleStack, UIView(), buttonStack].forEach(bottomStack.addArrangedSubview)
    }

    private func configureLayout() {
        layer.cornerRadius = Constants.cornerRadius
        layer.shadowColor = UIColor(.ui.border).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: Constants.cornerRadius).cgPath
        layer.backgroundColor = UIColor(.ui.homeCellBackground).cgColor
    }
}
