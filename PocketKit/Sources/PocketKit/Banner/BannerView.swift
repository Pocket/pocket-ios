import UIKit

class BannerView: UIView {
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 4

        return view
    }()

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

    private lazy var saveControl: UIControl = {
        let control: UIControl
        if #available(iOS 16, *) {
            var config = UIPasteControl.Configuration()
            config.displayMode = .labelOnly
            config.baseBackgroundColor = UIColor(.ui.teal2)
            config.baseForegroundColor = UIColor(.ui.white)

            control = UIPasteControl(configuration: config)
        } else {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor(.ui.teal2)
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

            control = UIButton(configuration: config)
        }

        control.setContentHuggingPriority(.required, for: .horizontal)
        return control
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
    private var primaryAction: (([NSItemProvider]) -> Void)?

    private var isLeftToRight: Bool {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight
    }
    private var gestureRecognizer: UISwipeGestureRecognizer

    override init(frame: CGRect) {
        gestureRecognizer = UISwipeGestureRecognizer(target: nil, action: nil)

        super.init(frame: frame)

        if #available(iOS 16, *) {
            (saveControl as? UIPasteControl)?.target = self
        }

        accessibilityIdentifier = "banner"
        layer.cornerRadius = 4

        gestureRecognizer.direction = .down
        addGestureRecognizer(gestureRecognizer)

        addSubview(borderView)
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        borderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            borderView.topAnchor.constraint(equalTo: topAnchor),
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
        ])

        if isLeftToRight {
            [textStackView, saveControl].forEach(stackView.addArrangedSubview)
        } else {
            [saveControl, textStackView].forEach(stackView.addArrangedSubview)
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            borderView.layer.borderColor = borderColor?.cgColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BannerView {
    func configure(model: BannerViewModel) {
        mainTextLabel.attributedText = model.attributedText

        backgroundColor = model.backgroundColor
        borderColor = model.borderColor
        borderView.layer.borderColor = borderColor?.cgColor

        primaryAction = model.primaryAction
        dismissAction = model.dismissAction
        gestureRecognizer.addTarget(self, action: #selector(dismiss))
    }

    @objc func dismiss() {
        guard let dismissAction = dismissAction else { return }
        dismissAction()
    }
}

extension BannerView {
    override func paste(itemProviders: [NSItemProvider]) {
        primaryAction?(itemProviders)
    }

    override func canPaste(_ itemProviders: [NSItemProvider]) -> Bool {
        itemProviders.contains { $0.canLoadObject(ofClass: URL.self) }
    }
}
