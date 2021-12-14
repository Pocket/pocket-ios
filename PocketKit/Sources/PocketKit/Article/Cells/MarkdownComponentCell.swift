import UIKit


class MarkdownComponentCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    lazy var textView: ArticleComponentTextView = {
        let textView = ArticleComponentTextView()
        textView.actionDelegate = self
        return textView
    }()

    weak var delegate: ArticleComponentTextCellDelegate?

    var selectedText: String {
        (textView.text as NSString).substring(with: textView.selectedRange)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    var attributedContent: NSAttributedString? {
        set {
            textView.attributedText = newValue
        }
        get {
            textView.attributedText
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
