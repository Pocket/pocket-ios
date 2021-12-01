import UIKit


class MarkdownComponentCell: UICollectionViewCell, PocketTextCell, PocketTextViewDelegate {
    lazy var textView: PocketTextView = {
        let textView = PocketTextView()
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.pocketDelegate = self
        return textView
    }()

    weak var delegate: PocketTextCellDelegate?

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
