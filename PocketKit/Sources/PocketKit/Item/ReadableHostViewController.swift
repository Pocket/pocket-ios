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
    private let tracker: Tracker
    private let moreButtonItem: UIBarButtonItem
    private var subscriptions: [AnyCancellable] = []

    private let mainViewModel: MainViewModel
    private var readableViewModel: ReadableViewModel
    
    weak var delegate: ReadableHostViewControllerDelegate?

    init(
        mainViewModel: MainViewModel,
        readableViewModel: ReadableViewModel,
        tracker: Tracker,
        source: Source
    ) {
        self.mainViewModel = mainViewModel
        self.readableViewModel = readableViewModel
        self.tracker = tracker
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
        
        readableViewModel.delegate = self
        readableViewModel.actions.sink { [weak self] actions in
            self?.buildOverflowMenu(from: actions)
        }.store(in: &subscriptions)
    }

    override func loadView() {
        view = UIView()
        
        let readableViewController = ReadableViewController(
            readerSettings: mainViewModel.readerSettings,
            tracker: tracker,
            viewModel: mainViewModel
        )
        readableViewController.readableViewModel = readableViewModel
        readableViewController.delegate = self

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
        
        menuActions.append(
            UIAction(
                title: "Display Settings",
                image: UIImage(systemName: "textformat.size"),
                handler: { [weak self] _ in
                    self?.showReaderSettings()
                }
            )
        )
        
        actions.forEach { action in
            let uiAction = UIAction(title: action.title,image: action.image) { _ in action.handler?() }
            uiAction.accessibilityIdentifier = action.accessibilityIdentifier
            menuActions.append(uiAction)
        }
        
        menuActions.append(
            UIAction(
                title: "Share",
                image: UIImage(systemName: "square.and.arrow.up"),
                handler: { [weak self] _ in
                    self?.share()
                }
            )
        )
        
        
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

    @objc
    private func showReaderSettings() {
        mainViewModel.isPresentingReaderSettings = true
    }

    var popoverAnchor: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?[0]
    }
}

// MARK: - Item Actions

extension ReadableHostViewController: ReadableViewModelDelegate {
    func readableViewModelDidFavorite(_ readableViewModel: ReadableViewModel) {
        track(identifier: .itemFavorite, url: readableViewModel.url)
    }

    func readableViewModelDidUnfavorite(_ readableViewModel: ReadableViewModel) {
        track(identifier: .itemUnfavorite, url: readableViewModel.url)
    }

    func readableViewModelDidArchive(_ readableViewModel: ReadableViewModel) {
        delegate?.readableHostViewControllerDidArchiveItem()
        track(identifier: .itemArchive, url: readableViewModel.url)
    }

    func readableViewModelDidDelete(_ readableViewModel: ReadableViewModel) {
        let actions = [
            UIAlertAction(title: "No", style: .default) { [weak self] _ in
                self?.mainViewModel.presentedAlert = nil
            },
            UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.mainViewModel.presentedAlert = nil

                guard let self = self else {
                    return
                }

                self.readableViewModel.delete()
                self.delegate?.readableHostViewControllerDidDeleteItem()
                self.track(identifier: .itemDelete, url: self.readableViewModel.url)
            }
        ]

        let alert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: actions,
            preferredAction: nil
        )
        mainViewModel.presentedAlert = alert
    }

    func readableViewModelDidSave(_ readableViewModel: ReadableViewModel) {
        track(identifier: .itemSave, url: readableViewModel.url)
    }
    
    private func share(additionalText: String? = nil) {
        mainViewModel.sharedActivity = readableViewModel.shareActivity(additionalText: additionalText)
        track(identifier: .itemShare, url: readableViewModel.url)
    }

    private func track(identifier: UIContext.Identifier, url: URL?) {
        guard let url = url else {
            return
        }

        let contexts: [Context] = [
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
        ]

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }
}

extension ReadableHostViewController: ReadableViewControllerDelegate {
    func readableViewController(_ controller: ReadableViewController, willOpenURL url: URL) {
        let additionalContexts: [Context] = [ContentContext(url: url)]

        let contentOpen = ContentOpenEvent(destination: .external, trigger: .click)
        let link = UIContext.articleView.link
        let contexts = additionalContexts + [link]
        tracker.track(event: contentOpen, contexts)
    }
    
    func readableViewControlled(_ controller: ReadableViewController, shareWithAdditionalText text: String?) {
        share(additionalText: text)
    }
}
