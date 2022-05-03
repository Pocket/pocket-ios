import UIKit
import Combine
import Textile


class SavedItemViewController: UIViewController {
    private let imageView = UIImageView(image: UIImage(asset: .logo))

    private let infoView = InfoView()

    private let dismissLabel = UILabel()

    private let viewModel: SavedItemViewModel

    private var infoViewModelSubscription: AnyCancellable?

    init(viewModel: SavedItemViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        infoViewModelSubscription = viewModel.$infoViewModel.receive(on: DispatchQueue.main).sink { [weak self] infoViewModel in
            self?.infoView.model = infoViewModel
        }
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

            dismissLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        if traitCollection.userInterfaceIdiom == .pad {
            NSLayoutConstraint.activate([
                infoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                infoView.widthAnchor.constraint(equalToConstant: 379)
            ])
        } else {
            NSLayoutConstraint.activate([
                infoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                infoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
            ])
        }

        dismissLabel.attributedText = viewModel.dismissAttributedText

        let tap = UITapGestureRecognizer(target: self, action: #selector(finish))
        view.addGestureRecognizer(tap)

        Task {
            await viewModel.save(from: extensionContext)
        }
    }

    @objc
    private func finish() {
        viewModel.finish(context: extensionContext)
    }
}
