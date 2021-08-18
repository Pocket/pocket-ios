import UIKit
import Combine
import Analytics
import Sync


protocol ItemViewControllerDelegate: AnyObject {
    func itemViewControllerDidTapReaderSettings(_ itemViewController: ItemViewController)
    func itemViewControllerDidTapWebViewButton(_ itemViewController: ItemViewController)
    func itemViewController(_ itemViewController: ItemViewController, didTapShareItem item: Item)
    func itemViewControllerDidDeleteItem(_ itemViewController: ItemViewController)
    func itemViewControllerDidArchiveItem(_ itemViewController: ItemViewController)
}

class ItemViewController: UIViewController {
    private let itemHost: ArticleViewController
    private let source: Source
    private var moreButtonItem: UIBarButtonItem?
    private var subscriptions: [AnyCancellable] = []
    private var observer: NSKeyValueObservation?


    var uiContext: SnowplowContext {
        return UIContext.articleView.screen
    }

    weak var delegate: ItemViewControllerDelegate?

    init(
        selection: ItemSelection,
        readerSettings: ReaderSettings,
        tracker: Tracker,
        source: Source
    ) {
        self.source = source
        itemHost = ArticleViewController(readerSettings: readerSettings, tracker: tracker)

        super.init(nibName: nil, bundle: nil)

        selection.$selectedItem.sink { [weak self] selectedItem in
            self?.itemHost.item = selectedItem
            self?.observer = selectedItem?.observe(\.isFavorite, options: [.initial]) { [weak self] _, _ in
                self?.resetNavbarRightBarButtonItems()
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

    func resetNavbarRightBarButtonItems() {
        guard let item = itemHost.item else {
            navigationItem.rightBarButtonItems = []
            return
        }

        let favorite: () -> UIAction = {
            if item.isFavorite {
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
        }

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                menu: UIMenu(
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
                        favorite(),
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
                    ])
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "safari"),
                style: .plain,
                target: self,
                action: #selector(showWebView)
            )
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("\(Self.self) cannot be instantiated from a xib/storyboard")
    }

    @objc
    private func showWebView() {
        delegate?.itemViewControllerDidTapWebViewButton(self)
    }

    @objc
    private func showReaderSettings() {
        delegate?.itemViewControllerDidTapReaderSettings(self)
    }
}

// MARK: - Item Actions

extension ItemViewController {
    private func favorite() {
        guard let item = itemHost.item else {
            return
        }

        source.favorite(item: item)
    }

    private func unfavorite() {
        guard let item = itemHost.item else {
            return
        }

        source.unfavorite(item: item)
    }

    private func archive() {
        guard let item = itemHost.item else {
            return
        }

        source.archive(item: item)
        delegate?.itemViewControllerDidArchiveItem(self)
    }

    private func delete() {
        guard let item = itemHost.item else {
            return
        }

        source.delete(item: item)
        delegate?.itemViewControllerDidDeleteItem(self)
    }

    private func share() {
        guard let item = itemHost.item else {
            return
        }

        delegate?.itemViewController(self, didTapShareItem: item)
    }
}
