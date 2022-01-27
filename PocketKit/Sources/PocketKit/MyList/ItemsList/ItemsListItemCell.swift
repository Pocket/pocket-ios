import UIKit
import Kingfisher


protocol ItemsListItemCellDelegate: AnyObject {
    func myListItemCellDidTapFavoriteButton(_ cell: ItemsListItemCell)
    func myListItemCellDidTapShareButton(_ cell: ItemsListItemCell)
    func myListItemCellDidTapDeleteButton(_ cell: ItemsListItemCell)
    func myListItemCellDidTapArchiveButton(_ cell: ItemsListItemCell)
}

class ItemsListItemCell: UICollectionViewCell {
    weak var delegate: ItemsListItemCellDelegate?

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
        static let textStackSpacing: CGFloat = 8
        static let topLevelStackSpacing: CGFloat = 14
        static let actionButtonHeight: CGFloat = 28
        static let mainStackSpacing: CGFloat = 8
        static let margins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxTitleLines

        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxDetailLines

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
        config.background.image = UIImage(asset: .share)
            .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "share"
        return button
    }()

    private let menuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.background.image = UIImage(asset: .overflow)
            .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal)

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

    private var thumbnailWidthConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "my-list-item"
        contentView.backgroundColor = UIColor(.ui.white1)

        let archiveAction = UIAction(title: "Archive", handler: { [weak self] _ in self?.handleArchive() })
        archiveAction.accessibilityIdentifier = "item-action-menu-archive"

        let deleteAction = UIAction(title: "Delete", handler: { [weak self] _ in self?.handleDelete() })
        deleteAction.accessibilityIdentifier = "item-action-menu-delete"

        menuButton.menu = UIMenu(children: [archiveAction, deleteAction])

        favoriteButton.addAction(UIAction { [weak self] _ in
            self?.handleFavorite()
        }, for: .primaryActionTriggered)

        shareButton.addAction(UIAction { [weak self] _ in
            self?.handleShare()
        }, for: .primaryActionTriggered)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(.ui.grey6)

        buttonStack.addArrangedSubview(UIView())
        buttonStack.addArrangedSubview(favoriteButton)
        buttonStack.addArrangedSubview(shareButton)
        buttonStack.addArrangedSubview(menuButton)

        mainContentView.addSubview(titleLabel)
        mainContentView.addSubview(detailLabel)
        mainContentView.addSubview(thumbnailView)

        listContentView.addSubview(mainContentView)
        listContentView.addSubview(buttonStack)

        contentView.addSubview(listContentView)
        contentView.layoutMargins = Constants.margins

        listContentView.translatesAutoresizingMaskIntoConstraints = false
        mainContentView.translatesAutoresizingMaskIntoConstraints = false
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

            titleLabel.topAnchor.constraint(equalTo: mainContentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: mainContentView.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            detailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            thumbnailView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            thumbnailView.trailingAnchor.constraint(equalTo: mainContentView.trailingAnchor),
            thumbnailView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
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

    private func handleArchive() {
        delegate?.myListItemCellDidTapArchiveButton(self)
    }

    private func handleShare() {
        delegate?.myListItemCellDidTapShareButton(self)
    }

    private func handleFavorite() {
        delegate?.myListItemCellDidTapFavoriteButton(self)
    }

    private func handleDelete() {
        delegate?.myListItemCellDidTapDeleteButton(self)
    }
}

extension ItemsListItemCell {
    struct Model: Hashable {
        let attributedTitle: NSAttributedString
        let attributedDetail: NSAttributedString
        let favoriteButtonImage: UIImage?
        let favoriteButtonAccessibilityLabel: String
        let thumbnailURL: URL?
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        let content = Self.defaultListContentConfiguration().updated(for: state)
        listContentView.configuration = content

        titleLabel.attributedText = state.model?.attributedTitle
        detailLabel.attributedText = state.model?.attributedDetail
        favoriteButton.configuration?.image = state.model?.favoriteButtonImage
        favoriteButton.accessibilityLabel = state.model?.favoriteButtonAccessibilityLabel

        thumbnailView.image = nil

        guard let thumbnailURL = state.model?.thumbnailURL else {
            thumbnailWidthConstraint.constant = 0
            return
        }

        thumbnailWidthConstraint.constant = Constants.thumbnailSize.width
        thumbnailView.kf.setImage(
            with: thumbnailURL,
            options: [
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
    static let model = UIConfigurationStateCustomKey("com.mozilla.pocket.next.MyListItemCell.model")
}

private extension UICellConfigurationState {
    var model: ItemsListItemCell.Model? {
        set { self[.model] = newValue }
        get { return self[.model] as? ItemsListItemCell.Model }
    }
}
