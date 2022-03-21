import UIKit
import Textile


class MainViewController: UIViewController {
    private let imageView = UIImageView(image: UIImage(asset: .logo))

    private let capsuleView = MainCapsuleView()

    private let dismissLabel = UILabel()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        Textiles.initialize()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(.ui.white1)

        view.addSubview(imageView)
        view.addSubview(capsuleView)
        view.addSubview(dismissLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        capsuleView.translatesAutoresizingMaskIntoConstraints = false
        dismissLabel.translatesAutoresizingMaskIntoConstraints = false

        let capsuleTopConstraint = NSLayoutConstraint(
            item: capsuleView,
            attribute: .top,
            relatedBy: .equal,
            toItem: view,
            attribute: .bottom,
            multiplier: 0.35,
            constant: 0
        )

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),

            capsuleTopConstraint,
            capsuleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            capsuleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            capsuleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            dismissLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        capsuleView.attributedText = NSAttributedString(string: "Saved to Pocket", style: .mainText)
        dismissLabel.attributedText = NSAttributedString(string: "Tap to Dismiss", style: .dismiss)

        let tap = UITapGestureRecognizer(target: self, action: #selector(finish))
        view.addGestureRecognizer(tap)
    }

    @objc
    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}

private class MainCapsuleView: UIView {
    private let imageView = UIImageView(image: UIImage(asset: .circleChecked))

    private let textLabel = UILabel()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textLabel])
        stackView.spacing = 28
        stackView.axis = .horizontal
        return stackView
    }()

    var attributedText: NSAttributedString? {
        get { textLabel.attributedText }
        set { textLabel.attributedText = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor(.ui.teal6)

        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.size.height / 2
    }
}

private extension Style {
    static let mainText: Self = .header.sansSerif.h2.with(color: .ui.teal2)
    static let dismiss: Self = .header.sansSerif.p3.with(color: .ui.grey5)
}
