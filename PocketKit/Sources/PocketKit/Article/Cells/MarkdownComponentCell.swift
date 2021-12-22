import UIKit


class MarkdownComponentCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }

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
        contentView.layoutMargins = Constants.layoutMargins

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            // set lower priority to avoid conflict if content turns out to be blank
                .with(priority: .defaultLow)
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
