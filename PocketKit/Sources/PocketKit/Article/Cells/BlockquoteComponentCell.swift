import UIKit


class BlockquoteComponentCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    
    struct Constants {
        static let dividerHeight: CGFloat = 5
        static let stackSpacing: CGFloat = 20
        static let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 23, right: 0)
    }

    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.grey1)
        return view
    }()
    
    private lazy var textView: ArticleComponentTextView = {
        let textView = ArticleComponentTextView()
        textView.actionDelegate = self
        return textView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Constants.stackSpacing
        stackView.alignment = .leading
        return stackView
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
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(textView)
        stackView.addArrangedSubview(divider)

        contentView.layoutMargins = Constants.layoutMargins
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            divider.widthAnchor.constraint(equalToConstant: 50),
            divider.heightAnchor.constraint(equalToConstant: Constants.dividerHeight),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
