import UIKit
import Combine
import Analytics
import Sync
import Textile

class ReadableHostViewController: UIViewController {
    private let moreButtonItem: UIBarButtonItem
    private var subscriptions: [AnyCancellable] = []
    private var readableViewModel: ReadableViewModel

    init(readableViewModel: ReadableViewModel) {
        self.readableViewModel = readableViewModel
        self.moreButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: nil
        )

        super.init(nibName: nil, bundle: nil)

        title = nil
        navigationItem.largeTitleDisplayMode = .never
        hidesBottomBarWhenPushed = true

        let archiveNavButton = UIBarButtonItem(
            image: UIImage(asset: .archive),
            style: .plain,
            target: self,
            action: #selector(archiveArticle)
        )
        archiveNavButton.accessibilityIdentifier = "archiveNavButton"

        navigationItem.rightBarButtonItems = [
            moreButtonItem,
            UIBarButtonItem(
                image: UIImage(systemName: "safari"),
                style: .plain,
                target: self,
                action: #selector(showWebView)
            ),
            archiveNavButton
        ]

        readableViewModel.actions.receive(on: DispatchQueue.main).sink { [weak self] actions in
            self?.buildOverflowMenu(from: actions)
        }.store(in: &subscriptions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        lockOrientation(.allButUpsideDown)
    }

    override func viewDidDisappear(_ animated: Bool) {
        lockOrientation(.portrait)
        super.viewDidDisappear(animated)
    }

    override func loadView() {
        view = UIView()

        let readableViewController = ReadableViewController(
            readable: readableViewModel,
            readerSettings: readableViewModel.readerSettings
        )
        readableViewController.delegate = readableViewModel

        readableViewController.willMove(toParent: self)
        addChild(readableViewController)
        view.addSubview(readableViewController.view)
        readableViewController.didMove(toParent: self)

        readableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            readableViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            readableViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            readableViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            readableViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func buildOverflowMenu(from actions: [ItemAction]) {
        moreButtonItem.menu = UIMenu(
            image: nil,
            identifier: nil,
            options: [],
            children: actions.compactMap(UIAction.init)
        )
    }

    required init?(coder: NSCoder) {
        fatalError("\(Self.self) cannot be instantiated from a xib/storyboard")
    }

    @objc
    private func showWebView() {
        readableViewModel.showWebReader()
    }

    @objc
    private func archiveArticle() {
        readableViewModel.archiveArticle()
    }

    var popoverAnchor: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?[0]
    }
}
