import UIKit

class BannerView: UIView {
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 22
        return stackView
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainTextLabel, detailTextLabel])
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()

    private lazy var saveButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(.ui.teal2)
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let button = UIButton(configuration: config)
        button.setContentHuggingPriority(.required, for: .horizontal)
        return button
    }()

    private let mainTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let detailTextLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private var borderColor: UIColor?
    private var dismissAction: (() -> Void)?
    private var isLeftToRight: Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
    }
    private var gestureRecognizer: UISwipeGestureRecognizer

    override init(frame: CGRect) {
        gestureRecognizer = UISwipeGestureRecognizer(target: nil, action: nil)

        super.init(frame: frame)
        accessibilityIdentifier = "banner"
        layer.borderWidth = 1
        layer.cornerRadius = 4

        gestureRecognizer.direction = .down
        addGestureRecognizer(gestureRecognizer)

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])

        if isLeftToRight {
            [textStackView, saveButton].forEach(stackView.addArrangedSubview)
        } else {
            [saveButton, textStackView].forEach(stackView.addArrangedSubview)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.borderColor = borderColor?.cgColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BannerView {
    func configure(model: BannerViewModel) {
        mainTextLabel.attributedText = model.attributedText
        detailTextLabel.attributedText = model.attributedDetailText
        saveButton.configuration?.attributedTitle = AttributedString(
            model.attributedButtonText
        )
        saveButton.addAction(UIAction { _ in model.primaryAction()}, for: .primaryActionTriggered)

        backgroundColor = model.backgroundColor
        borderColor = model.borderColor
        layer.borderColor = borderColor?.cgColor

        dismissAction = model.dismissAction
        gestureRecognizer.addTarget(self, action: #selector(dismiss))
    }

    @objc func dismiss() {
        guard let dismissAction = dismissAction else { return }
        dismissAction()
    }
}
