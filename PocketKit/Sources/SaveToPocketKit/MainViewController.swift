import UIKit
import Sync


class MainViewController: UIViewController {
    private let source: PocketSource

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        source = PocketSource(
            sessionProvider: FakeSessionProvider(),
            consumerKey: "lol",
            defaults: .standard,
            backgroundTaskManager: ExtensionTaskManager()
        )

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.text = "Hello, world"
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])


        if let items = extensionContext?.inputItems {
            for item in items {
                guard let _item = item as? NSExtensionItem,
                      let attachments = _item.attachments else { return }

                for attachment in attachments {
                    Task {
                        let url = try! await attachment.loadItem(forTypeIdentifier: "public.url", options: nil) as! URL
                        source.saveFromExtension(url: url)
                    }
                }
            }
            print(items)
        } else {
            print("no items")
        }
    }
}


class FakeSessionProvider: SessionProvider, Session {
    let guid = "no"
    let accessToken = "narp"

    var session: Session? {
        self
    }
}

class ExtensionTaskManager: BackgroundTaskManager {
    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> Int {
        return 0
    }

    func endTask(_ identifier: Int) {
        // k
    }
}


class SaveToPocketContext: NSExtensionContext {
    
}
