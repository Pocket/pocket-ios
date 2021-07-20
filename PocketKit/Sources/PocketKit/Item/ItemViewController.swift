import UIKit
import Combine
import Analytics


protocol ItemViewControllerDelegate: AnyObject {
    func itemViewControllerDidTapOverflowButton(_ itemViewController: ItemViewController)
    func itemViewControllerDidTapWebViewButton(_ itemViewController: ItemViewController)
}

class ItemViewController: UIViewController {
    private let itemHost: ArticleViewController
    private var subscriptions: [AnyCancellable] = []
    
    var uiContext: SnowplowContext {
        return UIContext.articleView.screen
    }

    weak var delegate: ItemViewControllerDelegate?

    init(selection: ItemSelection, readerSettings: ReaderSettings, tracker: Tracker) {
        itemHost = ArticleViewController(readerSettings: readerSettings, tracker: tracker)

        super.init(nibName: nil, bundle: nil)

        selection.$selectedItem.sink { selectedItem in
            self.itemHost.item = selectedItem
        }.store(in: &subscriptions)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                image: UIImage(systemName: "ellipsis"),
                style: .plain,
                target: self,
                action: #selector(showOverflow)
            ),
            UIBarButtonItem(
                image: UIImage(systemName: "safari"),
                style: .plain,
                target: self,
                action: #selector(showWebView)
            )
        ]
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

    required init?(coder: NSCoder) {
        fatalError("\(Self.self) cannot be instantiated from a xib/storyboard")
    }

    @objc
    private func showWebView() {
        delegate?.itemViewControllerDidTapWebViewButton(self)
    }

    @objc
    private func showOverflow() {
        delegate?.itemViewControllerDidTapOverflowButton(self)
    }
}
