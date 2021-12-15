import UIKit


protocol MyListItemCellDelegate: AnyObject {
    func myListItemCellDidTapFavoriteButton(_ cell: MyListItemCell)
    func myListItemCellDidTapShareButton(_ cell: MyListItemCell)
    func myListItemCellDidTapDeleteButton(_ cell: MyListItemCell)
    func myListItemCellDidTapArchiveButton(_ cell: MyListItemCell)
}

class MyListItemCell: UICollectionViewCell {
    weak var delegate: MyListItemCellDelegate?

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

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxTitleLines

        return label
    }()

    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxDetailLines

        return label
    }()

    let thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = UIColor(.ui.grey6)
        return imageView
    }()

    let favoriteButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.background.image = UIImage(asset: .favorite)
            .withTintColor(UIColor(.branding.amber4), renderingMode: .alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "favorite"
        return button
    }()

    let shareButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.background.image = UIImage(asset: .share)
            .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "share"
        return button
    }()

    let menuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .zero
        config.background.image = UIImage(asset: .overflow)
            .withTintColor(UIColor(.ui.grey5), renderingMode: .alwaysOriginal)

        let button = UIButton(configuration: config, primaryAction: nil)
        button.accessibilityIdentifier = "item-actions"
        button.showsMenuAsPrimaryAction = true

        return button
    }()

    private let topLevelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.topLevelStackSpacing
        return stack
    }()

    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = Constants.mainStackSpacing

        return stack
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.textStackSpacing
        return stack
    }()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.spacing = 10
        stack.axis = .horizontal

        return stack
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.grey6)

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        menuButton.menu = UIMenu(
            children: [
                UIAction(title: "Archive", handler: { [weak self] _ in self?.handleArchive() }),
                UIAction(title: "Delete", handler: { [weak self] _ in self?.handleDelete() }),
            ]
        )

        favoriteButton.addAction(UIAction { [weak self] _ in
            self?.handleFavorite()
        }, for: .primaryActionTriggered)

        shareButton.addAction(UIAction { [weak self] _ in
            self?.handleShare()
        }, for: .primaryActionTriggered)

        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor(.ui.grey6)

        topLevelStack.addArrangedSubview(mainStack)
        topLevelStack.addArrangedSubview(bottomStack)

        mainStack.addArrangedSubview(textStack)
        mainStack.addArrangedSubview(thumbnailView)

        bottomStack.addArrangedSubview(UIView())
        bottomStack.addArrangedSubview(favoriteButton)
        bottomStack.addArrangedSubview(shareButton)
        bottomStack.addArrangedSubview(menuButton)

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(detailLabel)

        contentView.addSubview(topLevelStack)
        contentView.addSubview(separator)

        contentView.layoutMargins = Constants.margins

        let buttonConstraints = [favoriteButton, menuButton, shareButton].flatMap { button in
            [
                button.widthAnchor.constraint(equalToConstant: Constants.actionButtonHeight),
                button.heightAnchor.constraint(equalTo: button.widthAnchor),
            ]
        }
        NSLayoutConstraint.activate(buttonConstraints)

        topLevelStack.translatesAutoresizingMaskIntoConstraints = false
        separator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailView.widthAnchor.constraint(equalToConstant: Constants.thumbnailSize.width),
            thumbnailView.heightAnchor.constraint(equalToConstant: Constants.thumbnailSize.height),
            topLevelStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            topLevelStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            topLevelStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            separator.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            separator.centerYAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
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
