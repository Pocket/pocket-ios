import UIKit


class ArticleMetadataCell: UICollectionViewCell {
    enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        static let stackSpacing: CGFloat = 16
    }

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    let bylineLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(labelStack)
        contentView.layoutMargins = Constants.layoutMargins

        labelStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.layoutMarginsGuide.leadingAnchor.constraint(equalTo: labelStack.leadingAnchor),
            contentView.layoutMarginsGuide.topAnchor.constraint(equalTo: labelStack.topAnchor),
            contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: labelStack.trailingAnchor),
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: labelStack.bottomAnchor),
        ])

        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(bylineLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArticleMetadataCell {
    static func height(of attributedString: NSAttributedString, width: CGFloat, numberOfLines: Int) -> CGFloat {
        guard !attributedString.string.isEmpty else {
            return 0
        }

        let maxHeight: CGFloat
        if let font = attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            maxHeight = font.lineHeight * CGFloat(numberOfLines)
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
}
