import UIKit

enum AccountSection {
    case main
}

enum AccountItem {
    case signOut
    case toggleAppBadge
}

class AccountViewController: UIViewController {
    private let model: AccountViewModel
    private let collectionView: UICollectionView
    private let dataSource: UICollectionViewDiffableDataSource<AccountSection, AccountItem>

    init(model: AccountViewModel) {
        self.model = model

        var layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        layoutConfig.backgroundColor = UIColor(.ui.white1)
        layoutConfig.separatorConfiguration.color = UIColor(.ui.grey6)
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.accessibilityIdentifier = "account"

        let registration: UICollectionView.CellRegistration<UICollectionViewListCell, AccountItem> = .init { cell, _, item in
            switch item {
            case .signOut:
                var content = cell.defaultContentConfiguration()
                content.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
                content.text = "Sign Out"

                cell.contentConfiguration = content
                cell.backgroundConfiguration?.backgroundColor = UIColor(.ui.white1)
            case .toggleAppBadge:
                model.toggleAppBadge()
            }
        }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = "Account"
        collectionView.delegate = self
    }

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var snapshot = NSDiffableDataSourceSnapshot<AccountSection, AccountItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.signOut], toSection: .main)

        dataSource.apply(snapshot)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }
}

extension AccountViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .signOut:
            model.signOut()
        case .toggleAppBadge:
            model.toggleAppBadge()
        default:
            break
        }
    }
}
