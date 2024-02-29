// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile
import SharedWithYou
import SharedPocketKit

/// Cell for the primary/hero items in Home and Collections
class HomeItemCell: UICollectionViewCell {
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

    let overflowButton: HomeCellActionButton = {
        let button = HomeCellActionButton(asset: .overflow)
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

    /// The top-most view containing the standard hero cell,
    /// that is the content of the item but not the accessory view (if applicable)
    private lazy var topView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The top-most stack view, that allows to add accessory views.
    /// If no accessory view is present, it only contains `topView`
    lazy var topStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [topView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    /// Add the attribution view if a valid shared with you url is found
    /// - Parameter urlString: the string representation of the url
    private func addAttributionView(_ urlString: String) async {
        guard let url = URL(string: urlString) else {
            return
        }
        // no need to re-add the same attribution view
        if let highlight = attributionView.highlight, highlight.url.absoluteString == urlString, attributionView.isDescendant(of: topStackView) {
            return
        }
        do {
            let highlight = try await SWHighlightCenter().highlight(for: url)
            attributionView.highlight = highlight
            // in case of reusing a cell, we just need to change the highlight without readding the attribution view to the hierarchy
            if !attributionView.isDescendant(of: topStackView) {
                topStackView.addArrangedSubview(attributionView)
            }
        } catch {
            Log.capture(message: "Unable to retrieve highlight for url: \(urlString) - Error: \(error)")
        }
    }

    private lazy var attributionView: SWAttributionView = {
        let attributionView = SWAttributionView()
        attributionView.translatesAutoresizingMaskIntoConstraints = false
        attributionView.displayContext = .summary
        return attributionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        topView.addSubview(thumbnailImageView)
        topView.addSubview(collectionLabel)
        topView.addSubview(titleLabel)
        topView.addSubview(excerptTextView)
        topView.addSubview(bottomStack)
        topView.layoutMargins = Constants.layoutMargins
        contentView.addSubview(topStackView)

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        collectionLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        excerptTextView.translatesAutoresizingMaskIntoConstraints = false
        bottomStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topView.layoutMarginsGuide.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: Constants.imageAspectRatio),

            collectionLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: Constants.textStackTopMargin),
            collectionLabel.leadingAnchor.constraint(equalTo: topView.layoutMarginsGuide.leadingAnchor),
            collectionLabel.trailingAnchor.constraint(equalTo: topView.layoutMarginsGuide.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: collectionLabel.bottomAnchor, constant: Constants.stackSpacing),
            titleLabel.leadingAnchor.constraint(equalTo: topView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: topView.layoutMarginsGuide.trailingAnchor),

            excerptTextView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Constants.textStackMiddleMargin),
            excerptTextView.leadingAnchor.constraint(equalTo: topView.layoutMarginsGuide.leadingAnchor),
            excerptTextView.trailingAnchor.constraint(equalTo: topView.layoutMarginsGuide.trailingAnchor),

            bottomStack.leadingAnchor.constraint(equalTo: topView.layoutMarginsGuide.leadingAnchor),
            bottomStack.trailingAnchor.constraint(equalTo: topView.layoutMarginsGuide.trailingAnchor),
            bottomStack.bottomAnchor.constraint(equalTo: topView.layoutMarginsGuide.bottomAnchor).with(priority: .required),

            topStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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

        if let url = model.sharedWithYouUrlString {
            Task {
                await addAttributionView(url)
            }
        } else {
            attributionView.removeFromSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }

    private func configureLayout() {
        topView.layoutIfNeeded()
        topView.layer.cornerRadius = Constants.cornerRadius
        topView.layer.shadowColor = UIColor(.ui.border).cgColor
        topView.layer.shadowOffset = .zero
        topView.layer.shadowOpacity = 1.0
        topView.layer.shadowRadius = 6
        topView.layer.shadowPath = UIBezierPath(roundedRect: topView.layer.bounds, cornerRadius: Constants.cornerRadius).cgPath
        topView.layer.backgroundColor = UIColor(.ui.homeCellBackground).cgColor
    }
}

extension HomeItemCell {
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

extension HomeItemCell {
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
