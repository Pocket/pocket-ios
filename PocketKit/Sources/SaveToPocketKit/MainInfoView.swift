import UIKit
import Textile


enum MainViewStyle {
    case `default`
    case error
}

class MainInfoView: UIView {
    private let capsuleView = MainCapsuleView()

    private let detailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [capsuleView, detailTextLabel])
        stackView.axis = .vertical
        stackView.spacing = 32
        return stackView
    }()

    var attributedText: NSAttributedString? {
        get { capsuleView.attributedText }
        set { capsuleView.attributedText = newValue }
    }

    var attributedDetailText: NSAttributedString? {
        get { detailTextLabel.attributedText }
        set { detailTextLabel.attributedText = newValue }
    }

    var style: MainViewStyle = .default {
        didSet { capsuleView.style = style }
    }

    init() {
        super.init(frame: .zero)

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class MainCapsuleView: UIView {
    private let imageView = UIImageView()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    var attributedText: NSAttributedString? {
        get { textLabel.attributedText }
        set { textLabel.attributedText = newValue }
    }

    var style: MainViewStyle = .default {
        didSet { updateStyle() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        updateStyle()

        addSubview(imageView)
        addSubview(textLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 1),

            textLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            textLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),

            heightAnchor.constraint(greaterThanOrEqualTo: imageView.heightAnchor, constant: 10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.height / 2
    }

    private func updateStyle() {
        switch style {
        case .default:
            backgroundColor = UIColor(.ui.teal6)
            imageView.image = UIImage(asset: .circleChecked)
        case .error:
            backgroundColor = UIColor(.ui.coral5)
            imageView.image = UIImage(asset: .error)
        }
    }
}
