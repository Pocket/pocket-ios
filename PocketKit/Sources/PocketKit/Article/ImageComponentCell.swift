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
            captionLabel.attributedText
        }
        set {
            captionLabel.attributedText = newValue
        }
    }

    var attributedCredit: NSAttributedString? {
        get {
            creditLabel.attributedText
        }
        set {
            creditLabel.attributedText = newValue
        }
    }

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true

        return label
    }()

    private let creditLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true

        return label
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
        stack.addArrangedSubview(captionLabel)
        stack.addArrangedSubview(creditLabel)

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
