// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile

/// View models of cels used in Unified Home can conform to this protocol
/// to use a set of standard elements
protocol ItemCellViewModel {
    var attributedCollection: NSAttributedString? { get }
    var attributedTitle: NSAttributedString { get }
    var attributedExcerpt: NSAttributedString? { get }
    var attributedDomain: NSAttributedString { get }
    var attributedTimeToRead: NSAttributedString { get }
    var imageURL: URL? { get }
    var saveButtonMode: ItemCellSaveButton.Mode { get }
    var overflowActions: [ItemAction]? { get }
    var primaryAction: ItemAction? { get }
}

class RecommendationCell: UICollectionViewCell {
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Constants.cornerRadius
        imageView.clipsToBounds = true
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.backgroundColor = UIColor(.ui.grey6)
        return imageView
    }()

    private let collectionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.numberOfCollectionLines
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "collection-label"
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.numberOfTitleLines
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let domainLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.numberOfSubtitleLines
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let timeToReadLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.numberOfSubtitleLines
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    let saveButton: ItemCellSaveButton = {
        let button = ItemCellSaveButton()
        button.accessibilityIdentifier = "save-button"
        return button
    }()

    let overflowButton: RecommendationButton = {
        let button = RecommendationButton(asset: .overflow)
        button.accessibilityIdentifier = "overflow-button"
        button.showsMenuAsPrimaryAction = true
        return button
    }()

    private let subtitleStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillProportionally
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 0
        return stack
    }()

    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .equalSpacing
        stack.axis = .horizontal
        return stack
    }()

    lazy var excerptTextView: UILabel = {
        let textView = UILabel()
        textView.numberOfLines = 0
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(collectionLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(excerptTextView)
        contentView.addSubview(bottomStack)
        contentView.layoutMargins = Constants.layoutMargins

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        collectionLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        excerptTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: Constants.imageAspectRatio),

            collectionLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: Constants.textStackTopMargin),
            collectionLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            collectionLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: Constants.stackSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            excerptTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.textStackMiddleMargin),
            excerptTextView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            excerptTextView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            bottomStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).with(priority: .required),

            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        [UIView(), domainLabel, timeToReadLabel, UIView()].forEach(subtitleStack.addArrangedSubview)
        [saveButton, overflowButton].forEach(buttonStack.addArrangedSubview)
        [subtitleStack, UIView(), buttonStack].forEach(bottomStack.addArrangedSubview)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(model: ItemCellViewModel) {
        titleLabel.attributedText = model.attributedTitle
        domainLabel.attributedText = model.attributedDomain
        timeToReadLabel.attributedText = model.attributedTimeToRead
        excerptTextView.attributedText = model.attributedExcerpt

        saveButton.mode = model.saveButtonMode

        if let attributedCollection = model.attributedCollection {
            collectionLabel.isHidden = false
            collectionLabel.attributedText = attributedCollection
        } else {
            collectionLabel.isHidden = true
        }

        if model.attributedTimeToRead.string.isEmpty {
            timeToReadLabel.isHidden = true
        } else {
            timeToReadLabel.isHidden = false
        }

        if let saveAction = UIAction(model.primaryAction) {
            saveButton.addAction(saveAction, for: .primaryActionTriggered)
        }

        let menuActions = model.overflowActions?.compactMap(UIAction.init) ?? []
        overflowButton.menu = UIMenu(children: menuActions)

        let imageWidth = bounds.width
                - Constants.layoutMargins.left
                - Constants.layoutMargins.right

        let imageSize = CGSize(
            width: imageWidth,
            height: (imageWidth * Constants.imageAspectRatio).rounded(.down)
        )
        thumbnailImageView.kf.indicatorType = .activity
        thumbnailImageView.kf.setImage(
            with: model.imageURL,
            options: [
                .callbackQueue(.dispatch(.global(qos: .userInteractive))),
                .backgroundDecode,
                .scaleFactor(UIScreen.main.scale),
                .processor(
                    ResizingImageProcessor(
                        referenceSize: imageSize,
                        mode: .aspectFill
                    ).append(
                        another: CroppingImageProcessor(
                            size: imageSize
                        )
                    )
                )
            ]
        )
    }

    override func layoutSubviews() {
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

extension RecommendationCell {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let textStackTopMargin: CGFloat = 16
        static let imageAspectRatio: CGFloat = 9/16
        static let numberOfCollectionLines = 1
        static let numberOfTitleLines = 3
        static let numberOfSubtitleLines = 2
        static let numberOfTimeToReadLines = 1
        static let layoutMargins = UIEdgeInsets(top: 0, left: Margins.normal.rawValue, bottom: Margins.normal.rawValue, right: Margins.normal.rawValue)
        static let stackSpacing: CGFloat = 4
        static let textStackMiddleMargin: CGFloat = 12
        static let textStackBottomMargin: CGFloat = 12
    }
}

extension RecommendationCell {
    static func fullHeight(viewModel: ItemCellViewModel, availableWidth: CGFloat) -> CGFloat {
        let adjustedWidth = availableWidth - Constants.layoutMargins.left - Constants.layoutMargins.right
        let imageHeight = (availableWidth * Constants.imageAspectRatio).rounded(.up)

        var collectionHeight: CGFloat = 0
        if let attributedCollection = viewModel.attributedCollection {
            collectionHeight = adjustedHeight(
                of: attributedCollection,
                availableWidth: adjustedWidth,
                numberOfLines: Constants.numberOfTitleLines
            )
        }

        let titleHeight = adjustedHeight(
            of: viewModel.attributedTitle,
            availableWidth: adjustedWidth,
            numberOfLines: Constants.numberOfTitleLines
        )

        var excerptHeight: CGFloat = 0
        if let excerpt = viewModel.attributedExcerpt {
            excerptHeight = height(
                of: excerpt,
                width: adjustedWidth,
                numberOfLines: nil
            )
        }

        let domainHeight = adjustedHeight(
            of: viewModel.attributedDomain,
            availableWidth: adjustedWidth / 2,
            numberOfLines: Constants.numberOfSubtitleLines
        )

        let timeToReadHeight = adjustedHeight(
            of: viewModel.attributedTimeToRead,
            availableWidth: adjustedWidth / 2,
            numberOfLines: Constants.numberOfTimeToReadLines
        )

        let stackHeight = Constants.stackSpacing + domainHeight + Constants.stackSpacing + timeToReadHeight + Constants.stackSpacing

        return Constants.layoutMargins.top
        + imageHeight
        + Constants.textStackTopMargin
        + collectionHeight
        + Constants.stackSpacing
        + titleHeight
        + Constants.textStackMiddleMargin
        + excerptHeight
        + Constants.textStackBottomMargin
        + stackHeight
        + Constants.layoutMargins.bottom
    }

    static func height(of attributedString: NSAttributedString, width: CGFloat, numberOfLines: Int? = nil) -> CGFloat {
        guard !attributedString.string.isEmpty else {
            return 0
        }

        let maxHeight: CGFloat
        if let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont, let numberOfLines {
            let lineSpacing: CGFloat
            if let paragraphStyle = attributedString.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
                lineSpacing = paragraphStyle.lineSpacing
            } else {
                lineSpacing = 0
            }

            maxHeight = font.lineHeight * CGFloat(numberOfLines) + lineSpacing * CGFloat(numberOfLines - 1)
        } else {
            maxHeight = .greatestFiniteMagnitude
        }

        let rect = attributedString.boundingRect(
            with: CGSize(width: width, height: maxHeight),
            options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin],
            context: nil
        )

        return rect.height.rounded(.up)
    }

    private static func adjustedHeight(
        of string: NSAttributedString,
        availableWidth: CGFloat,
        numberOfLines: Int?
    ) -> CGFloat {
        guard !string.string.isEmpty else {
            return 0
        }

        let stringForMeasurement: NSAttributedString
        if let style = string.attribute(.style, at: 0, effectiveRange: nil) as? Style {
            let measurementStyle = style.with { $0.with(lineBreakMode: .none) }
            stringForMeasurement = NSAttributedString(string: string.string, style: measurementStyle)
        } else {
            stringForMeasurement = string
        }

        return height(
            of: stringForMeasurement,
            width: availableWidth,
            numberOfLines: numberOfLines
        )
    }
}
