import UIKit
import Textile


class SavedItemViewController: UIViewController {
    private let imageView = UIImageView(image: UIImage(asset: .logo))

    private let infoView = InfoView()

    private let dismissLabel = UILabel()

    private let viewModel: SavedItemViewModel

    init(viewModel: SavedItemViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(.ui.white1)

        view.addSubview(imageView)
        view.addSubview(infoView)
        view.addSubview(dismissLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        infoView.translatesAutoresizingMaskIntoConstraints = false
        dismissLabel.translatesAutoresizingMaskIntoConstraints = false

        let capsuleTopConstraint = NSLayoutConstraint(
            item: infoView,
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
            infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            infoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),

            dismissLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        infoView.model = viewModel.infoViewModel
        dismissLabel.attributedText = viewModel.dismissAttributedText

        let tap = UITapGestureRecognizer(target: self, action: #selector(finish))
        view.addGestureRecognizer(tap)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Task {
            await viewModel.save(from: extensionContext)
        }
    }

    @objc
    private func finish() {
        viewModel.finish(context: extensionContext)
    }
}
