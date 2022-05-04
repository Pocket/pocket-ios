import UIKit
import Kingfisher
import Textile


protocol RecommendationCellViewModel {
    var attributedTitle: NSAttributedString { get }
    var attributedDetail: NSAttributedString { get }
    var attributedExcerpt: NSAttributedString { get }
    var imageURL: URL? { get }
    var saveButtonMode: RecommendationSaveButton.Mode { get }
}

class RecommendationCell: UICollectionViewCell {
    enum Mode {
        case hero
        case mini
    }

    var mode: Mode = .hero {
        didSet {
            adjustLayoutForMode()
        }
    }

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(.ui.grey6)
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = RecommendationCell.numberOfTitleLines
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    private let excerptLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = RecommendationCell.numberOfExcerptLines
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()

    let saveButton: RecommendationSaveButton = {
        let button = RecommendationSaveButton()
        button.accessibilityIdentifier = "save-button"

        return button
    }()

    let overflowButton: RecommendationOverflowButton = {
        let button = RecommendationOverflowButton()
        button.accessibilityIdentifier = "report-button"
        return button
    }()

    private let textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.setContentHuggingPriority(.required, for: .vertical)
        return stack
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        return stack
    }()

    private var textStackTopConstraint: NSLayoutConstraint
    private var buttonStackTopConstraintHero: NSLayoutConstraint
    private var buttonStackTopConstraintMini: NSLayoutConstraint

    override init(frame: CGRect) {
        textStackTopConstraint = textStack.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 0)

        buttonStackTopConstraintHero = buttonStack.topAnchor.constraint(
            equalTo: textStack.bottomAnchor,
            constant: Hero.buttonStackTopMargin
        )

        buttonStackTopConstraintMini = buttonStack.topAnchor.constraint(
            greaterThanOrEqualTo: textStack.bottomAnchor,
            constant: Mini.buttonStackTopMargin
        )

        super.init(frame: frame)

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(textStack)
        contentView.addSubview(buttonStack)

        contentView.layoutMargins = Self.layoutMargins

        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        textStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: Self.imageAspectRatio),

            textStackTopConstraint,
            textStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),

            buttonStackTopConstraintHero,
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])

        [titleLabel, subtitleLabel, excerptLabel].forEach(textStack.addArrangedSubview)
        [saveButton, UIView(), overflowButton].forEach(buttonStack.addArrangedSubview)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func configure(model: RecommendationCellViewModel) {
        titleLabel.attributedText = model.attributedTitle
        subtitleLabel.attributedText = model.attributedDetail
        excerptLabel.attributedText = model.attributedExcerpt

        saveButton.mode = model.saveButtonMode

        let imageWidth = bounds.width
        - RecommendationCell.layoutMargins.left
        - RecommendationCell.layoutMargins.right

        let imageSize = CGSize(
            width: imageWidth,
            height: imageWidth * RecommendationCell.imageAspectRatio
        )

        thumbnailImageView.kf.indicatorType = .activity
        thumbnailImageView.kf.setImage(
            with: model.imageURL,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(ResizingImageProcessor(
                    referenceSize: imageSize,
                    mode: .aspectFill
                ).append(
                    another: CroppingImageProcessor(size: imageSize)
                )),
            ]
        )
    }
}

extension RecommendationCell {
    private func adjustLayoutForMode() {
        switch mode {
        case .hero:
            textStackTopConstraint.constant = Hero.textStackTopMargin
            textStack.spacing = Hero.textStackSpacing
            excerptLabel.isHidden = false
            saveButton.isTitleHidden = false
            subtitleLabel.numberOfLines = Hero.numberOfSubtitleLines

            buttonStackTopConstraintHero.isActive = true
            buttonStackTopConstraintMini.isActive = false
        case .mini:
            textStackTopConstraint.constant = Mini.textStackTopMargin
            textStack.spacing = Mini.textStackSpacing
            excerptLabel.isHidden = true
            saveButton.isTitleHidden = true
            subtitleLabel.numberOfLines = Mini.numberOfSubtitleLines

            buttonStackTopConstraintHero.isActive = false
            buttonStackTopConstraintMini.isActive = true
        }
    }
}

extension RecommendationCell {
    struct Hero {
        static let textStackTopMargin: CGFloat = 16
        static let buttonStackTopMargin: CGFloat = 10
        static let textStackSpacing: CGFloat = 8
        static let numberOfSubtitleLines = 1
    }

    struct Mini {
        static let textStackTopMargin: CGFloat = 10
        static let buttonStackTopMargin: CGFloat = 4
        static let textStackSpacing: CGFloat = 4
        static let numberOfSubtitleLines = 2
    }

    static let layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    static let imageAspectRatio: CGFloat = 9/16
    static let numberOfTitleLines = 3
    static let numberOfExcerptLines = 3
    static let saveButtonHeight: CGFloat = 21
}

extension RecommendationCell {
    static func miniHeight(viewModel: RecommendationCellViewModel, availableWidth: CGFloat) -> CGFloat {
        let adjustedWidth = (availableWidth / 2).rounded(.down) - Self.layoutMargins.left - Self.layoutMargins.right
        let imageHeight = adjustedWidth * Self.imageAspectRatio

        let titleHeight = adjustedHeight(
            of: viewModel.attributedTitle,
            availableWidth: adjustedWidth,
            numberOfLines: numberOfTitleLines
        )

        let detailHeight = adjustedHeight(
            of: viewModel.attributedDetail,
            availableWidth: adjustedWidth,
            numberOfLines: Hero.numberOfSubtitleLines
        )

        return Self.layoutMargins.top
        + imageHeight
        + Mini.textStackTopMargin
        + titleHeight
        + Mini.textStackSpacing
        + detailHeight
        + Mini.buttonStackTopMargin
        + Self.saveButtonHeight
        + Self.layoutMargins.bottom
    }

    static func fullHeight(viewModel: RecommendationCellViewModel, availableWidth: CGFloat) -> CGFloat {
        let adjustedWidth = availableWidth - Self.layoutMargins.left - Self.layoutMargins.right
        let imageHeight = (adjustedWidth * Self.imageAspectRatio).rounded(.up)

        let titleHeight = adjustedHeight(
            of: viewModel.attributedTitle,
            availableWidth: adjustedWidth,
            numberOfLines: numberOfTitleLines
        )
        let detailHeight = adjustedHeight(
            of: viewModel.attributedDetail,
            availableWidth: adjustedWidth,
            numberOfLines: Hero.numberOfSubtitleLines
        )
        let excerptHeight = adjustedHeight(
            of: viewModel.attributedExcerpt,
            availableWidth: adjustedWidth,
            numberOfLines: numberOfExcerptLines
        )

        return Self.layoutMargins.top
        + imageHeight
        + Hero.textStackTopMargin
        + titleHeight
        + Hero.textStackSpacing
        + detailHeight
        + Hero.textStackSpacing
        + excerptHeight
        + Hero.buttonStackTopMargin
        + Self.saveButtonHeight
        + Self.layoutMargins.bottom
    }

    static func height(of attributedString: NSAttributedString, width: CGFloat, numberOfLines: Int) -> CGFloat {
        guard !attributedString.string.isEmpty else {
            return 0
        }
        
        let maxHeight: CGFloat
        if let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
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
        numberOfLines: Int
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
