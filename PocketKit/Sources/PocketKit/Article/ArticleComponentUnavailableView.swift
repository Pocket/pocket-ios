import UIKit
import Textile

private extension Style {
    static let label: Self = .body.sansSerif.with(size: .p3)
    static let button: Self = .body.sansSerif.with(size: .p3).with(color: .ui.white).with(weight: .semibold)
}

class ArticleComponentUnavailableView: UIView {
    private lazy var label: UILabel = {
        return UILabel()
    }()

    private lazy var button: UIButton = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor(.ui.teal2)
        config.attributedTitle = AttributedString(
            NSAttributedString(
                string: "Open in Web View".localized(),
                style: .button
            )
        )
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)

        let button = UIButton(
            configuration: config,
            primaryAction: UIAction { _ in
                self.action?()
            }
        )
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()

    private lazy var topDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.grey6)
        return view
    }()

    private lazy var bottomDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(.ui.grey6)
        return view
    }()

    var action: (() -> Void)?

    var text: String? {
        get {
            label.text
        }
        set {
            label.attributedText = newValue.flatMap { NSAttributedString(string: $0, style: .label) }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(topDivider)
        addSubview(stackView)
        addSubview(bottomDivider)

        topDivider.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topDivider.topAnchor.constraint(equalTo: topAnchor),
            topDivider.widthAnchor.constraint(equalTo: widthAnchor),
            topDivider.heightAnchor.constraint(equalToConstant: 1),

            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
            stackView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),

            bottomDivider.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomDivider.widthAnchor.constraint(equalTo: widthAnchor),
            bottomDivider.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
