import UIKit
import Combine
import Analytics
import Sync
import Textile


protocol ReadableHostViewControllerDelegate: AnyObject {
    func readableHostViewControllerDidDeleteItem()
    func readableHostViewControllerDidArchiveItem()
}

class ReadableHostViewController: UIViewController {
    private let moreButtonItem: UIBarButtonItem
    private var subscriptions: [AnyCancellable] = []

    private let mainViewModel: MainViewModel
    private var readableViewModel: ReadableViewModel
    
    weak var delegate: ReadableHostViewControllerDelegate?

    init(
        mainViewModel: MainViewModel,
        readableViewModel: ReadableViewModel
    ) {
        self.mainViewModel = mainViewModel
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
        
        readableViewModel.actions.sink { [weak self] actions in
            self?.buildOverflowMenu(from: actions)
        }.store(in: &subscriptions)
        
        readableViewModel.events.sink { [weak self] event in
            self?.handleEvent(event)
        }.store(in: &subscriptions)
    }

    override func loadView() {
        view = UIView()
        
        let readableViewController = ReadableViewController(
            readerSettings: mainViewModel.readerSettings,
            viewModel: mainViewModel
        )
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

    func buildOverflowMenu(from actions: [ReadableAction]) {
        var menuActions: [UIAction] = []
        
        actions.forEach { action in
            let uiAction = UIAction(title: action.title,image: action.image) { _ in action.handler?() }
            uiAction.accessibilityIdentifier = action.accessibilityIdentifier
            menuActions.append(uiAction)
        }
        
        moreButtonItem.menu = UIMenu(
            image: nil,
            identifier: nil,
            options: [],
            children: menuActions
        )
    }

    required init?(coder: NSCoder) {
        fatalError("\(Self.self) cannot be instantiated from a xib/storyboard")
    }

    @objc
    private func showWebView() {
        mainViewModel.presentedWebReaderURL = readableViewModel.url
    }

    var popoverAnchor: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?[0]
    }
}

// MARK: - Item Actions

extension ReadableHostViewController {
    private func handleEvent(_ event: ReadableEvent) {
        switch event {
        case .archive:
            delegate?.readableHostViewControllerDidArchiveItem()
        case .delete:
            delegate?.readableHostViewControllerDidDeleteItem()
        }
    }
}
