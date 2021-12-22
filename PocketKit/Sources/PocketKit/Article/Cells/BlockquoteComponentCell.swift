import UIKit


class BlockquoteComponentCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    
    struct Constants {
        static let dividerWidth: CGFloat = 5
        static let stackSpacing: CGFloat = 12
        static let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 23, right: 0)
    }

    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.grey3)
        return view
    }()
    
    private lazy var textView: ArticleComponentTextView = {
        let textView = ArticleComponentTextView()
        textView.actionDelegate = self
        return textView
    }()
    
    var attributedBlockquote: NSAttributedString? {
        get {
            textView.attributedText
        }
        set {
            textView.attributedText = newValue
        }
    }
    
    weak var delegate: ArticleComponentTextCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(divider)
        contentView.addSubview(textView)
        contentView.layoutMargins = Constants.layoutMargins

        textView.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: Constants.dividerWidth),
            divider.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            divider.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            divider.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: Constants.stackSpacing),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
