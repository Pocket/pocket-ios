import UIKit
import Combine
import Analytics
import Sync


protocol ItemViewControllerDelegate: AnyObject {
    func itemViewControllerDidDeleteItem(_ itemViewController: ItemViewController)
    func itemViewControllerDidArchiveItem(_ itemViewController: ItemViewController)
}

class ItemViewController: UIViewController {
    private let itemHost: ArticleViewController
    private let source: Source
    private let tracker: Tracker
    private let moreButtonItem: UIBarButtonItem
    private var subscriptions: [AnyCancellable] = []
    private var observer: NSKeyValueObservation?
    private let model: MainViewModel

    var uiContext: SnowplowContext {
        return UIContext.articleView.screen
    }

    weak var delegate: ItemViewControllerDelegate?

    init(
        model: MainViewModel,
        tracker: Tracker,
        source: Source
    ) {
        self.source = source
        self.tracker = tracker
        self.itemHost = ArticleViewController(readerSettings: model.readerSettings, tracker: tracker)
        self.model = model
        self.moreButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: nil
        )

        super.init(nibName: nil, bundle: nil)
        
        title = nil
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItems = [
            moreButtonItem,
            UIBarButtonItem(
                image: UIImage(systemName: "safari"),
                style: .plain,
                target: self,
                action: #selector(showWebView)
            )
        ]

        model.$selectedItem.sink { [weak self] selectedItem in
            self?.itemHost.item = selectedItem
            self?.observer = selectedItem?.observe(\.isFavorite, options: [.initial]) { [weak self] _, _ in
                self?.buildOverflowMenu()
            }
        }.store(in: &subscriptions)
    }

    override func loadView() {
        view = UIView()
        view.addSubview(itemHost.view)
        addChild(itemHost)
        itemHost.didMove(toParent: self)

        itemHost.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemHost.view.topAnchor.constraint(equalTo: view.topAnchor),
            itemHost.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemHost.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            itemHost.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func buildOverflowMenu() {
        moreButtonItem.menu = UIMenu(
            image: nil,
            identifier: nil,
            options: [],
            children: [
                UIAction(
                    title: "Display Settings",
                    image: UIImage(systemName: "textformat.size"),
                    handler: { [weak self] _ in
                        self?.showReaderSettings()
                    }
                ),
                {
                    if model.selectedItem?.isFavorite == true {
                        return UIAction(
                            title: "Unfavorite",
                            image: UIImage(systemName: "star.slash"),
                            handler: { [weak self] _ in
                                self?.unfavorite()
                            }
                        )
                    } else {
                        return UIAction(
                            title: "Favorite",
                            image: UIImage(systemName: "star"),
                            handler: { [weak self] _ in
                                self?.favorite()
                            }
                        )
                    }
                }(),
                UIAction(
                    title: "Archive",
                    image: UIImage(systemName: "archivebox"),
                    handler: { [weak self] _ in
                        self?.archive()
                    }
                ),
                UIAction(
                    title: "Delete",
                    image: UIImage(systemName: "trash"),
                    handler: { [weak self] _ in
                        self?.delete()
                    }
                ),
                UIAction(
                    title: "Share",
                    image: UIImage(systemName: "square.and.arrow.up"),
                    handler: { [weak self] _ in
                        self?.share()
                    }
                ),
            ]
        )
    }

    required init?(coder: NSCoder) {
        fatalError("\(Self.self) cannot be instantiated from a xib/storyboard")
    }

    @objc
    private func showWebView() {
        model.presentedWebReaderURL = model.selectedItem?.url
    }

    @objc
    private func showReaderSettings() {
        model.isPresentingReaderSettings = true
    }

    var popoverAnchor: UIBarButtonItem? {
        navigationItem.rightBarButtonItems?[0]
    }
}

// MARK: - Item Actions

extension ItemViewController {
    private func favorite() {
        guard let item = model.selectedItem else {
            return
        }

        source.favorite(item: item)
        track(identifier: .itemFavorite, item: item)
    }

    private func unfavorite() {
        guard let item = model.selectedItem else {
            return
        }

        source.unfavorite(item: item)
        track(identifier: .itemUnfavorite, item: item)
    }

    private func archive() {
        guard let item = model.selectedItem else {
            return
        }

        source.archive(item: item)
        delegate?.itemViewControllerDidArchiveItem(self)
        track(identifier: .itemArchive, item: item)
    }

    private func delete() {
        guard let item = model.selectedItem else {
            return
        }

        source.delete(item: item)
        delegate?.itemViewControllerDidDeleteItem(self)
        track(identifier: .itemDelete, item: item)
    }

    private func share() {
        guard let item = model.selectedItem else {
            return
        }

        model.sharedActivity = PocketItemActivity(item: item, additionalText: nil)
        track(identifier: .itemShare, item: item)
    }

    private func track(identifier: UIIdentifier, item: Item) {
        guard let url = item.url else {
            return
        }

        let contexts: [SnowplowContext] = [
            uiContext,
            UIContext.button(identifier: identifier),
            Content(url: url)
        ]

        let event = Engagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }
}
