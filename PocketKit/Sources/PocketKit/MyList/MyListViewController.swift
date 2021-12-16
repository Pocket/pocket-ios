import UIKit
import Sync
import CoreData
import Combine
import Kingfisher


class MyListViewController: UIViewController {
    private let model: MyListViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<String, NSManagedObjectID>!

    init(model: MyListViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)

        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
            let archiveAction = UIContextualAction(
                style: .normal,
                title: "Archive"
            ) { _, _, completion in
                self.model.item(at: indexPath)?.archive()
                completion(true)
            }
            archiveAction.backgroundColor = UIColor(.ui.lapis1)

            return UISwipeActionsConfiguration(actions: [archiveAction])
        }

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(using: config)
        )

        navigationItem.title = "My List"
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = "my-list"
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.handleRefresh()
            })
        )

        let registration: UICollectionView.CellRegistration<MyListItemCell, NSManagedObjectID> = .init { [weak self] cell, indexPath, itemID in
            self?.configure(cell: cell, indexPath: indexPath, itemID: itemID)
        }

        self.dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemID in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemID)
        }

        model.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            self?.handle(myListEvent: event)
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        try? model.fetch()
    }

    private func handleRefresh() {
        model.refresh { [weak self] in
            self?.handleRefreshCompletion()
        }
    }

    private func handleRefreshCompletion() {
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }

    private func configure(cell: MyListItemCell, indexPath: IndexPath, itemID: NSManagedObjectID) {
        guard let item = model.item(at: indexPath) else {
            return
        }

        cell.delegate = self
        cell.model = .init(
            attributedTitle: item.attributedTitle,
            attributedDetail: item.attributedDetail,
            favoriteButtonImage: item.favoriteButtonImage,
            favoriteButtonAccessibilityLabel: item.favoriteButtonAccessibilityLabel,
            thumbnailURL: item.thumbnailURL
        )
    }

    private func handle(myListEvent event: MyListViewModel.Event) {
        switch event {
        case .itemUpdated(let id):
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems([id])
            dataSource.apply(snapshot, animatingDifferences: true)

        case .itemsLoaded(let snapshot):
            dataSource.apply(snapshot, animatingDifferences: true)

        case .itemSelected(let selectedItem):
            deselect(selectedItem)
        }
    }

    private func deselect(_ selectedItem: SavedItem?) {
        guard selectedItem == nil else {
            return
        }

        self.collectionView.indexPathsForSelectedItems?.forEach { selectedIndexPath in
            self.collectionView.deselectItem(at: selectedIndexPath, animated: false)
        }
    }
}

extension MyListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.selectItem(at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        model.item(at: indexPath)?.trackImpression()
    }
}

extension MyListViewController: MyListItemCellDelegate {
    func myListItemCellDidTapFavoriteButton(_ cell: MyListItemCell) {
        item(for: cell)?.toggleFavorite()
    }

    func myListItemCellDidTapShareButton(_ cell: MyListItemCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }

        model.shareItem(at: indexPath)
    }

    func myListItemCellDidTapDeleteButton(_ cell: MyListItemCell) {
        guard let item = item(for: cell) else {
            return
        }

        let actions = [
            UIAlertAction(title: "No", style: .default) { [weak self] _ in
                self?.model.presentedAlert = nil
            },
            UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.model.presentedAlert = nil
                item.delete()
            }
        ]

        let alert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: actions,
            preferredAction: nil
        )
        model.presentedAlert = alert
    }

    func myListItemCellDidTapArchiveButton(_ cell: MyListItemCell) {
        item(for: cell)?.archive()
    }

    private func item(for cell: MyListItemCell) -> MyListItemViewModel? {
        collectionView.indexPath(for: cell)
            .flatMap { model.item(at: $0) }
    }
}
