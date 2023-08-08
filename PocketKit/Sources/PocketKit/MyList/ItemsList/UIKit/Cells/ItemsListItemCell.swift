// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher

class ItemsListItemCell: UICollectionViewListCell {
    var model: Model? {
        didSet {
            setNeedsUpdateConfiguration()
        }
    }

    override var configurationState: UICellConfigurationState {
        var state = super.configurationState
        state.model = model
        return state
    }

    private static func defaultListContentConfiguration() -> UIListContentConfiguration {
        .cell()
    }

    private let listContentView = UIListContentView(
        configuration: ItemsListItemCell.defaultListContentConfiguration()
    )

    enum Constants {
        static let cornerRadius: CGFloat = 4
        static let thumbnailSize = CGSize(width: 90, height: 60)
        static let maxTitleLines = 3
        static let maxDetailLines = 2
        static let maxCollectionLines = 1
        static let textStackSpacing: CGFloat = 8
        static let topLevelStackSpacing: CGFloat = 14
        static let actionButtonHeight: CGFloat = 28
        static let actionButtonImageSize = CGSize(width: 20, height: 20)
        static let mainStackSpacing: CGFloat = 8
        static var collectionLabelSpacing: CGFloat = 4
        static let margins = UIEdgeInsets(top: Margins.normal.rawValue, left: Margins.normal.rawValue, bottom: Margins.normal.rawValue, right: Margins.normal.rawValue)
    }

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
        return label
    }()

    private let detailLabel: UILabel = {
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
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "favorite"
        return button
    }()

    private let shareButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = UIImage(asset: .share)
            .resized(to: Constants.actionButtonImageSize)
            .withTintColor(UIColor(.ui.grey8), renderingMode: .alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "item-action-share"
        return button
    }()

    private let menuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.image = UIImage(asset: .overflow)
            .resized(to: Constants.actionButtonImageSize)
            .withTintColor(UIColor(.ui.grey8), renderingMode: .alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "item-actions"
        button.showsMenuAsPrimaryAction = true

        return button
    }()

    private let mainContentView = UIView()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.axis = .horizontal

        return stack
    }()

    private let tagsStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.axis = .horizontal

        return stack
    }()

    private var tagButton: UIButton {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(asset: .tag)
            .resized(to: CGSize(width: 13, height: 13))
            .withTintColor(UIColor(.ui.grey4))
        config.imagePadding = 5

        config.background.cornerRadius = 4
        config.background.backgroundColor = UIColor(.ui.grey7)
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "tag-button"
        return button
    }

    private var thumbnailWidthConstraint: NSLayoutConstraint!
    private var titleSectionConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "saves-item"

        buttonStack.addArrangedSubview(tagsStack)
        buttonStack.addArrangedSubview(UIView())
        buttonStack.addArrangedSubview(favoriteButton)
        buttonStack.addArrangedSubview(shareButton)
        buttonStack.addArrangedSubview(menuButton)

        mainContentView.addSubview(collectionLabel)
        mainContentView.addSubview(titleLabel)
        mainContentView.addSubview(detailLabel)
        mainContentView.addSubview(thumbnailView)

        listContentView.addSubview(mainContentView)
        listContentView.addSubview(buttonStack)

        contentView.addSubview(listContentView)
        contentView.layoutMargins = Constants.margins

        listContentView.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.translatesAutoresizingMaskIntoConstraints = false
        collectionLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false

        thumbnailWidthConstraint = thumbnailView.widthAnchor.constraint(
            equalToConstant: Constants.thumbnailSize.width
        ).with(priority: .required)

        NSLayoutConstraint.activate(
            [favoriteButton, menuButton, shareButton].flatMap { button -> [NSLayoutConstraint] in
                [
                    button.widthAnchor.constraint(equalToConstant: Constants.actionButtonHeight).with(priority: .required),
                    button.heightAnchor.constraint(equalTo: button.widthAnchor).with(priority: .required)
                ]
            }
        )

        titleSectionConstraint = titleLabel.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: 0)

        NSLayoutConstraint.activate([
            listContentView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            listContentView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            listContentView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            listContentView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            listContentView.bottomAnchor.constraint(equalTo: buttonStack.bottomAnchor),

            mainContentView.topAnchor.constraint(equalTo: listContentView.topAnchor),
            mainContentView.leadingAnchor.constraint(equalTo: listContentView.leadingAnchor),
            mainContentView.trailingAnchor.constraint(equalTo: listContentView.trailingAnchor),
            mainContentView.bottomAnchor.constraint(greaterThanOrEqualTo: thumbnailView.bottomAnchor),
            mainContentView.bottomAnchor.constraint(greaterThanOrEqualTo: detailLabel.bottomAnchor),

            collectionLabel.topAnchor.constraint(equalTo: mainContentView.topAnchor),
            collectionLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor),

            titleSectionConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            thumbnailView.topAnchor.constraint(equalTo: mainContentView.topAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor),
            thumbnailView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20),
            thumbnailView.heightAnchor.constraint(equalToConstant: Constants.thumbnailSize.height).with(priority: .required),
            thumbnailWidthConstraint!,

            buttonStack.topAnchor.constraint(equalTo: mainContentView.bottomAnchor, constant: 14).with(priority: .defaultHigh),
            buttonStack.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ItemsListItemCell {
    enum CellStyle {
        case bordered
        case plain
    }
    struct Model: Hashable {
        let attributedTitle: NSAttributedString
        let attributedDetail: NSAttributedString
        let attributedTags: [NSAttributedString]?
        let attributedTagCount: NSAttributedString?
        let attributedCollection: NSAttributedString?

        let thumbnailURL: URL?

        let shareAction: ItemAction?
        let favoriteAction: ItemAction?
        let overflowActions: [ItemAction]
        let filterByTagAction: UIAction?
        let trackOverflow: UIAction?
        let swiftUITrackOverflow: ItemAction?
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        let content = Self.defaultListContentConfiguration().updated(for: state)
        listContentView.configuration = content

        var bgConfig = backgroundConfiguration?.updated(for: state)
        bgConfig?.backgroundColorTransformer = UIConfigurationColorTransformer { color in
            state.isSelected ? UIColor(.ui.grey6) : UIColor(.ui.white1)
        }
        backgroundConfiguration = bgConfig

        if let attributedCollection = model?.attributedCollection {
            titleSectionConstraint.constant = 4
            collectionLabel.isHidden = false
            collectionLabel.attributedText = attributedCollection
        } else {
            titleSectionConstraint.constant = 0
            collectionLabel.isHidden = true
        }

        titleLabel.attributedText = state.model?.attributedTitle
        detailLabel.attributedText = state.model?.attributedDetail

        tagsStack.subviews.forEach { view in
            view.removeFromSuperview()
        }

        if let attributedTags = state.model?.attributedTags {
            attributedTags.forEach { attributedTag in
                let button = tagButton
                button.configuration?.attributedTitle = AttributedString(attributedTag)
                if let uiAction = state.model?.filterByTagAction {
                    button.addAction(uiAction, for: .primaryActionTriggered)
                }
                tagsStack.addArrangedSubview(button)
            }
            let countLabel = UILabel()
            countLabel.attributedText = state.model?.attributedTagCount
            tagsStack.addArrangedSubview(countLabel)
        }

        favoriteButton.accessibilityLabel = state.model?.favoriteAction?.title
        favoriteButton.accessibilityIdentifier = state.model?.favoriteAction?.accessibilityIdentifier
        favoriteButton.configuration?.image = state.model?.favoriteAction?.image?.resized(to: Constants.actionButtonImageSize)

        if let favoriteAction = UIAction(state.model?.favoriteAction) {
            favoriteButton.addAction(favoriteAction, for: .primaryActionTriggered)
        }

        if let shareAction = UIAction(state.model?.shareAction) {
            shareButton.addAction(shareAction, for: .primaryActionTriggered)
        } else {
            shareButton.isHidden = true
        }

        let menuActions = state.model?.overflowActions.compactMap(UIAction.init) ?? []
        menuButton.menu = UIMenu(children: menuActions)

        if let trackAction = state.model?.trackOverflow {
            menuButton.addAction(trackAction, for: .menuActionTriggered)
        }

        thumbnailView.image = nil
        guard let thumbnailURL = state.model?.thumbnailURL else {
            thumbnailWidthConstraint.constant = 0
            return
        }

        thumbnailWidthConstraint.constant = Constants.thumbnailSize.width
        thumbnailView.kf.indicatorType = .activity
        thumbnailView.kf.setImage(
            with: thumbnailURL,
            options: [
                .callbackQueue(.dispatch(.global(qos: .userInteractive))),
                .backgroundDecode,
                .scaleFactor(UIScreen.main.scale),
                .processor(
                    ResizingImageProcessor(
                        referenceSize: Self.Constants.thumbnailSize,
                        mode: .aspectFill
                    ).append(
                        another: CroppingImageProcessor(
                            size: Self.Constants.thumbnailSize
                        )
                    )
                )
            ]
        )
    }
}

private extension UIConfigurationStateCustomKey {
    static let model = UIConfigurationStateCustomKey("com.mozilla.pocket.next.SavesItemCell.model")
}

private extension UICellConfigurationState {
    var model: ItemsListItemCell.Model? {
        get { return self[.model] as? ItemsListItemCell.Model }
        set { self[.model] = newValue }
    }
}
