import UIKit
import Kingfisher


class ImageComponentCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()

    var attributedCaption: NSAttributedString? {
        get {
            captionTextView.attributedText
        }
        set {
            captionTextView.attributedText = newValue
        }
    }

    var attributedCredit: NSAttributedString? {
        get {
            creditTextView.attributedText
        }
        set {
            creditTextView.attributedText = newValue
        }
    }

    private let captionTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.isEditable = false
        textView.isScrollEnabled = false

        return textView
    }()

    private let creditTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = .zero
        textView.isEditable = false
        textView.isScrollEnabled = false

        return textView
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(stack)
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(captionTextView)
        stack.addArrangedSubview(creditTextView)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
