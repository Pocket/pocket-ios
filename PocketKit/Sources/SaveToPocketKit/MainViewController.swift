import UIKit
import Textile
import Apollo
import SharedPocketKit
import Sync


class MainViewController: UIViewController {
    private let imageView = UIImageView(image: UIImage(asset: .logo))

    private let infoView = MainInfoView()

    private let dismissLabel = UILabel()

    private let viewModel: MainViewModel

    convenience init() {
        Textiles.initialize()

        let appSession = AppSession()

        self.init(
            viewModel: MainViewModel(
                appSession: appSession,
                saveService: PocketSaveService(
                    apollo: ApolloClient.createDefault(
                        sessionProvider: appSession,
                        consumerKey: Keys.shared.pocketApiConsumerKey
                    ),
                    backgroundActivityPerformer: ProcessInfo.processInfo,
                    space: Space(container: .init(storage: .shared))
                )
            )
        )
    }

    init(viewModel: MainViewModel) {
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
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            dismissLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dismissLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        dismissLabel.attributedText = NSAttributedString(string: "Tap to Dismiss", style: .dismiss)

        let tap = UITapGestureRecognizer(target: self, action: #selector(finish))
        view.addGestureRecognizer(tap)

        updateUI()

        Task {
            await viewModel.save(from: extensionContext)
        }
    }

    private func updateUI() {
        infoView.style = viewModel.style
        infoView.attributedText = viewModel.attributedText
        infoView.attributedDetailText = viewModel.attributedDetailText
    }

    @objc
    private func finish() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}

private extension Style {
    static let dismiss: Self = .header.sansSerif.p3.with(color: .ui.grey5).with { $0.with(lineHeight: .explicit(22)) }
}
