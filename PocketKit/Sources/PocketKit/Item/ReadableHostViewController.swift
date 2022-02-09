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

        navigationItem.rightBarButtonItems = [
            moreButtonItem,
            UIBarButtonItem(
                image: UIImage(systemName: "safari"),
                style: .plain,
                target: self,
                action: #selector(showWebView)
            )
        ]
        
        readableViewModel.actions.receive(on: DispatchQueue.main).sink { [weak self] actions in
            self?.buildOverflowMenu(from: actions)
        }.store(in: &subscriptions)
    }

    override func loadView() {
        view = UIView()
        
        let readableViewController = ReadableViewController(readerSettings: readableViewModel.readerSettings)
        readableViewController.readableViewModel = readableViewModel
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

    var popoverAnchor: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?[0]
    }
}
