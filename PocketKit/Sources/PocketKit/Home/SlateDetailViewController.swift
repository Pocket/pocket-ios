import UIKit


class SlateDetailViewController: UIViewController {
    private let label = UILabel()

    override func loadView() {
        view = UIView()
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = "slate-detail"
        view.backgroundColor = .white
        label.text = "Slate Detail Placeholder"
    }
}
