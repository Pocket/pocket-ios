import UIKit
import Kingfisher
import Textile


class HomeCarouselItemCell: UICollectionViewCell {
    var model: Model? {
        didSet {
            reconfigure()
        }
    }

    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let thumbnailSize = CGSize(width: 90, height: 60)
        static let maxTitleLines = 2
        static let maxDetailLines = 2
        static let textStackSpacing: CGFloat = 8
        static let topLevelStackSpacing: CGFloat = 14
        static let actionButtonImageSize = CGSize(width: 20, height: 20)
        static let mainStackSpacing: CGFloat = 8
        static let layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxTitleLines
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private let domainLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.maxDetailLines
        return label
    }()
    
    private let timeToReadLabel: UILabel = {
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
    
    let saveButton: RecommendationSaveButton = {
        let button = RecommendationSaveButton()
        button.accessibilityIdentifier = "save-button"
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        return button
    }()

    private let overflowButton: UIButton = {
        let button = RecommendationOverflowButton()
        button.accessibilityIdentifier = "overflow-button"
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let mainContentView = UIView()
    
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
        stack.axis = .horizontal
        return stack
    }()
    
    private let subtitleStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }()
    
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
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

        thumbnailWidthConstraint = thumbnailView.widthAnchor.constraint(
            equalToConstant: Constants.thumbnailSize.width
        ).with(priority: .required)

        contentView.layoutMargins = Constants.layoutMargins
        NSLayoutConstraint.activate([
            mainContentStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            mainContentStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            mainContentStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            thumbnailView.heightAnchor.constraint(equalToConstant: Constants.thumbnailSize.height).with(priority: .required),
            thumbnailWidthConstraint!,

            bottomStack.leadingAnchor.constraint(equalTo: mainContentStack.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: mainContentStack.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo:  contentView.layoutMarginsGuide.bottomAnchor).with(priority: .required),
        ])
        
        [UIView(), domainLabel, timeToReadLabel, UIView()].forEach(subtitleStack.addArrangedSubview)
        [favoriteButton, saveButton, overflowButton].forEach(buttonStack.addArrangedSubview)
        [titleLabel, thumbnailView].forEach(mainContentStack.addArrangedSubview)
        [subtitleStack, UIView(), buttonStack].forEach(bottomStack.addArrangedSubview)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeCarouselItemCell {
    struct Model: Hashable {
        let title: String?
        let domain: String?
        let timeToRead: String?
        let thumbnailURL: URL?
        let saveButtonMode: RecommendationSaveButton.Mode?
        
        init(item: ItemsListItem) {
            self.title = item.title
            self.domain = item.domainMetadata?.name ?? item.domain ?? item.bestURL?.host
            let timeToRead = item.timeToRead ?? 0
            self.timeToRead = timeToRead > 0 ? "\(timeToRead) min read" : nil
            self.thumbnailURL = imageCacheURL(for: item.topImageURL)
            self.saveButtonMode = nil
        }
        
        init(viewModel: HomeRecommendationCellViewModel) {
            self.title = viewModel.title
            self.domain = viewModel.domain
            self.timeToRead = viewModel.timeToRead
            self.thumbnailURL = viewModel.imageURL
            self.saveButtonMode = viewModel.saveButtonMode
        }

        var favoriteAction: ItemAction? = nil
        var overflowActions: [ItemAction]? = nil
        
        var attributedTitle: NSAttributedString {
            NSAttributedString(string: title ?? "", style: .title)
        }
        
        var attributedDomain: NSAttributedString {
            return NSAttributedString(string: domain ?? "", style: .domain)
        }
        
        var attributedTimeToRead: NSAttributedString {
            return NSAttributedString(string: timeToRead ?? "", style: .timeToRead)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }

    func reconfigure() {
        titleLabel.attributedText = model?.attributedTitle
        domainLabel.attributedText = model?.attributedDomain
        timeToReadLabel.attributedText = model?.attributedTimeToRead
        
        if model?.attributedTimeToRead.string == "" {
            timeToReadLabel.isHidden = true
        } else {
            timeToReadLabel.isHidden = false
        }
        
        favoriteButton.accessibilityLabel = model?.favoriteAction?.title
        favoriteButton.accessibilityIdentifier = model?.favoriteAction?.accessibilityIdentifier
        favoriteButton.configuration?.image = model?.favoriteAction?.image?.resized(to: Constants.actionButtonImageSize)

        if let favoriteAction = UIAction(model?.favoriteAction) {
            favoriteButton.addAction(favoriteAction, for: .primaryActionTriggered)
        }
        
        if let mode = model?.saveButtonMode {
            saveButton.isHidden = false
            saveButton.mode = mode
        } else {
            saveButton.isHidden = true
        }

        let menuActions = model?.overflowActions?.compactMap(UIAction.init) ?? []
        overflowButton.menu = UIMenu(children: menuActions)

        thumbnailView.image = nil
        guard let thumbnailURL = model?.thumbnailURL else {
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
    
    override func layoutSubviews() {
        contentView.layer.masksToBounds = false
        layer.cornerRadius = Constants.cornerRadius
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layer.shadowColor = UIColor(.ui.border).cgColor
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowOpacity = 1.0
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowPath = UIBezierPath(roundedRect: contentView.layer.bounds, cornerRadius: contentView.layer.cornerRadius).cgPath
        contentView.layer.backgroundColor = UIColor(.ui.white1).cgColor
    }
}

private extension UIConfigurationStateCustomKey {
    static let model = UIConfigurationStateCustomKey("com.mozilla.pocket.next.HomeCarouselItemCell.model")
}

private extension UICellConfigurationState {
    var model: HomeCarouselItemCell.Model? {
        set { self[.model] = newValue }
        get { return self[.model] as? HomeCarouselItemCell.Model }
    }
}

private extension Style {
    static let title: Style = .header.sansSerif.h8.with { paragraph in
        paragraph.with(lineSpacing: 4).with(lineBreakMode: .byTruncatingTail)
    }

    static let domain: Style = .header.sansSerif.p4.with(color: .ui.grey5).with(weight: .medium).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }
    
    static let timeToRead: Style = .header.sansSerif.p4.with(color: .ui.grey5).with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }
}
