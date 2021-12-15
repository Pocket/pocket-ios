import UIKit
import Sync
import CoreData
import Combine
import Kingfisher


class MyListViewController: UIViewController {
    private let model: MyListViewModel
    private let mainViewModel: MainViewModel

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

    private lazy var layout = UICollectionViewCompositionalLayout { [weak self] _, env in
        return MyListLayoutBuilder.buildLayout(model: self?.model, env: env)
    }

    private var registration: UICollectionView.CellRegistration<MyListItemCell, NSManagedObjectID>!

    private var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!

    private var subscriptions: [AnyCancellable] = []

    init(model: MyListViewModel, mainViewModel: MainViewModel) {
        self.model = model
        self.mainViewModel = mainViewModel

        super.init(nibName: nil, bundle: nil)

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

        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemID in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: itemID)
        }

        model.$items.receive(on: DispatchQueue.main).sink { [weak self] savedItems in
            self?.updateSnapshot()
        }.store(in: &subscriptions)

        model.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            self?.handle(myListEvent: event)
        }.store(in: &subscriptions)

        mainViewModel.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] selectedItem in
            self?.deselect(selectedItem)
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
        guard let item = model.items?[indexPath.item] else {
            return
        }

        cell.titleLabel.attributedText = item.attributedTitle
        cell.detailLabel.attributedText = item.attributedDetail
        cell.favoriteButton.configuration?.background.image = item.favoriteButtonImage
        cell.favoriteButton.accessibilityLabel = item.favoriteButtonAccessibilityLabel
        item.loadThumbnail(into: cell)
        cell.delegate = self
    }

    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()

        guard let items = model.items, !items.isEmpty else {
            dataSource.apply(snapshot, animatingDifferences: true)
            return
        }

        snapshot.appendSections([0])
        snapshot.appendItems(items.map({ $0.objectID }), toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func handle(myListEvent event: MyListViewModel.Event) {
        switch event {
        case .itemUpdated(let id):
            var snapshot = dataSource.snapshot()
            snapshot.reloadItems([id])
            dataSource.apply(snapshot, animatingDifferences: true)
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
        mainViewModel.selectedItem = model.items?[indexPath.item].savedItem
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        model.items?[indexPath.item].trackImpression()
    }
}

extension MyListViewController: MyListItemCellDelegate {
    func myListItemCellDidTapFavoriteButton(_ cell: MyListItemCell) {
        item(for: cell)?.toggleFavorite()
    }

    func myListItemCellDidTapShareButton(_ cell: MyListItemCell) {
        mainViewModel.sharedActivity = item(for: cell).flatMap {
            PocketItemActivity(item: $0.savedItem)
        }
    }

    func myListItemCellDidTapDeleteButton(_ cell: MyListItemCell) {
        item(for: cell)?.delete()
    }

    func myListItemCellDidTapArchiveButton(_ cell: MyListItemCell) {
        item(for: cell)?.archive()
    }

    private func item(for cell: MyListItemCell) -> MyListItemViewModel? {
        collectionView.indexPath(for: cell)
            .flatMap { model.items?[$0.item] }
    }
}
