import UIKit

enum SettingsSection {
    case main
}

enum SettingsItem {
    case signOut
}

class SettingsViewController: UIViewController {
    private let model: SettingsViewModel
    private let collectionView: UICollectionView
    private let dataSource: UICollectionViewDiffableDataSource<SettingsSection, SettingsItem>

    init(model: SettingsViewModel) {
        self.model = model

        let layoutConfig = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: layoutConfig)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.accessibilityIdentifier = "settings"

        let registration: UICollectionView.CellRegistration<UICollectionViewListCell, SettingsItem> = .init { cell, _, item in
            switch item {
            case .signOut:
                var content = cell.defaultContentConfiguration()
                content.image = UIImage(systemName: "rectangle.portrait.and.arrow.right")
                content.text = "Sign Out"

                cell.contentConfiguration = content
            }
        }

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: item)
        }

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = "Settings"
        collectionView.delegate = self
    }

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var snapshot = NSDiffableDataSourceSnapshot<SettingsSection, SettingsItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems([.signOut], toSection: .main)

        dataSource.apply(snapshot)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch dataSource.itemIdentifier(for: indexPath) {
        case .signOut:
            model.signOut()
        default:
            break
        }
    }
}
