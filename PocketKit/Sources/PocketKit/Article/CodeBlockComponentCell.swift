import UIKit


class CodeBlockComponentCell: UICollectionViewCell {
    struct Constants {
        static let contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    private var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(.ui.grey6)
        view.contentInset = Constants.contentInset
        return view
    }()
    
    lazy var textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = .zero
        view.isEditable = false
        view.isScrollEnabled = false
        view.dataDetectorTypes = []
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(scrollView)
        scrollView.addSubview(textView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            textView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            textView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
