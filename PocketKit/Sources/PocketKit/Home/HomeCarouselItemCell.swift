// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile

protocol HomeCarouselItemCellModel {
    var thumbnailURL: URL? { get }
    var saveButtonMode: RecommendationSaveButton.Mode? { get }
    var favoriteAction: ItemAction? { get }
    var overflowActions: [ItemAction]? { get }
    var saveAction: ItemAction? { get }
    var attributedCollection: NSAttributedString? { get }
    var attributedTitle: NSAttributedString { get }
    var attributedDomain: NSAttributedString { get }
    var attributedTimeToRead: NSAttributedString { get }
}

class HomeCarouselItemCell: UICollectionViewCell {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let maxTitleLines = 3
        static let maxDetailLines = 2
        static let maxCollectionLines = 1
        static let actionButtonImageSize = CGSize(width: 20, height: 20)
        static let layoutMargins = UIEdgeInsets(top: Margins.normal.rawValue, left: Margins.normal.rawValue, bottom: Margins.normal.rawValue, right: Margins.normal.rawValue)
        static let stackSpacing: CGFloat = 4
    }

    private let collectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxCollectionLines
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = true
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
        let button = RecommendationButton(asset: .favorite)
        button.accessibilityIdentifier = "favorite"
        return button
    }()

    let saveButton: RecommendationSaveButton = {
        let button = RecommendationSaveButton()
        button.accessibilityIdentifier = "save-button"
        return button
    }()

    private let overflowButton: UIButton = {
        let button = RecommendationButton(asset: .overflow)
        button.accessibilityIdentifier = "overflow-button"
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let mainContentView = UIView()

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
        accessibilityIdentifier = "home-carousel-item"

        contentView.addSubview(mainContentStack)
        contentView.addSubview(bottomStack)
        contentView.layoutMargins = Constants.layoutMargins

        mainContentStack.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        thumbnailWidthConstraint = thumbnailView.widthAnchor.constraint(
            equalToConstant: StyleConstants.thumbnailSize.width
        ).with(priority: .required)

        contentView.layoutMargins = Constants.layoutMargins
        NSLayoutConstraint.activate([
            mainContentStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainContentStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainContentStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            thumbnailView.heightAnchor.constraint(equalToConstant: StyleConstants.thumbnailSize.height).with(priority: .required),
            thumbnailWidthConstraint!,

            bottomStack.leadingAnchor.constraint(equalTo: mainContentStack.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: mainContentStack.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).with(priority: .required),

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        [UIView(), domainLabel, timeToReadLabel, UIView()].forEach(subtitleStack.addArrangedSubview)
        [favoriteButton, saveButton, overflowButton].forEach(buttonStack.addArrangedSubview)
        [collectionLabel, titleLabel].forEach(textStack.addArrangedSubview)
        [textStack, thumbnailView].forEach(mainContentStack.addArrangedSubview)
        [subtitleStack, UIView(), buttonStack].forEach(bottomStack.addArrangedSubview)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCarouselItemCell {
    func configure(model: HomeCarouselItemCellModel) {
        titleLabel.attributedText = model.attributedTitle
        domainLabel.attributedText = model.attributedDomain
        timeToReadLabel.attributedText = model.attributedTimeToRead

        if let attributedCollection = model.attributedCollection {
            collectionLabel.isHidden = false
            collectionLabel.attributedText = attributedCollection
        } else {
            collectionLabel.isHidden = true
        }

        if model.attributedTimeToRead.string.isEmpty {
            timeToReadLabel.isHidden = true
            subtitleStack.setCustomSpacing(0, after: timeToReadLabel)
            subtitleStack.setCustomSpacing(Constants.layoutMargins.bottom, after: domainLabel)
        } else {
            timeToReadLabel.isHidden = false
            subtitleStack.setCustomSpacing(Constants.stackSpacing, after: domainLabel)
            subtitleStack.setCustomSpacing(Constants.layoutMargins.bottom, after: timeToReadLabel)
        }

        favoriteButton.accessibilityLabel = model.favoriteAction?.title
        favoriteButton.accessibilityIdentifier = model.favoriteAction?.accessibilityIdentifier
        favoriteButton.configuration?.image = model.favoriteAction?.image?.resized(to: Constants.actionButtonImageSize)

        if let favoriteAction = UIAction(model.favoriteAction) {
            favoriteButton.addAction(favoriteAction, for: .primaryActionTriggered)
        }

        if let mode = model.saveButtonMode {
            saveButton.isHidden = false
            saveButton.mode = mode
        } else {
            saveButton.isHidden = true
        }

        if let saveAction = UIAction(model.saveAction) {
            saveButton.addAction(saveAction, for: .primaryActionTriggered)
        }

        let menuActions = model.overflowActions?.compactMap(UIAction.init) ?? []
        overflowButton.menu = UIMenu(children: menuActions)

        thumbnailView.image = nil
        guard let thumbnailURL = model.thumbnailURL else {
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

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.masksToBounds = false
        layer.cornerRadius = Constants.cornerRadius
        layer.shadowColor = UIColor(.ui.border).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.backgroundColor = UIColor(.ui.homeCellBackground).cgColor
    }
}
