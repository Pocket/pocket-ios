import UIKit


class ArticleMetadataCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    enum Constants {
        static let stackSpacing: CGFloat = 10
    }

    struct Model {
        let byline: NSAttributedString?
        let publishedDate: NSAttributedString?
        let title: NSAttributedString?
    }

    private let bylineTextView = ArticleComponentTextView()
    private let publishedDateTextView = ArticleComponentTextView()
    private let titleTextView = ArticleComponentTextView()

    private var metaStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    weak var delegate: ArticleComponentTextCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        bylineTextView.actionDelegate = self
        publishedDateTextView.actionDelegate = self
        titleTextView.actionDelegate = self

        contentView.addSubview(textStack)
        textStack.addArrangedSubview(metaStack)
        textStack.addArrangedSubview(titleTextView)
        metaStack.addArrangedSubview(bylineTextView)
        metaStack.addArrangedSubview(publishedDateTextView)

        textStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: textStack.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: textStack.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Model) {
        bylineTextView.attributedText = model.byline
        publishedDateTextView.attributedText = model.publishedDate
        titleTextView.attributedText = model.title

        bylineTextView.isHidden = model.byline == nil
        publishedDateTextView.isHidden = model.publishedDate == nil
        titleTextView.isHidden = model.title == nil

        if model.byline == nil && model.publishedDate == nil {
            textStack.spacing = 0
        } else {
            textStack.spacing = Constants.stackSpacing
        }
    }
}
