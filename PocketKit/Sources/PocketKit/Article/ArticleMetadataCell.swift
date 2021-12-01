import UIKit


class ArticleMetadataCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    enum Constants {
        static let stackSpacing: CGFloat = 0
    }

    private lazy var titleTextView: ArticleComponentTextView = {
        let textView = ArticleComponentTextView()
        textView.actionDelegate = self
        return textView
    }()

    private lazy var bylineTextView: ArticleComponentTextView = {
        let textView = ArticleComponentTextView()
        textView.actionDelegate = self
        return textView
    }()

    private var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.stackSpacing
        return stack
    }()
    
    var attributedTitle: NSAttributedString? {
        set {
            titleTextView.attributedText = newValue
        }
        get {
            titleTextView.attributedText
        }
    }
    
    var attributedByline: NSAttributedString? {
        set {
            bylineTextView.attributedText = newValue
        }
        get {
            bylineTextView.attributedText
        }
    }
    
    weak var delegate: ArticleComponentTextCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(labelStack)

        labelStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: labelStack.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: labelStack.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: labelStack.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: labelStack.bottomAnchor),
        ])

        labelStack.addArrangedSubview(titleTextView)
        labelStack.addArrangedSubview(bylineTextView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
