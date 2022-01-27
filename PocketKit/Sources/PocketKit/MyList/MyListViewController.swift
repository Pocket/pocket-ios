import UIKit
import Sync
import CoreData
import Combine
import Kingfisher


enum ItemListSection: Int, CaseIterable {
    case filters
    case items
}

enum ItemListCell<ItemIdentifier: Hashable>: Hashable {
    case filterButton(ItemListFilter)
    case item(ItemIdentifier)
}

enum ItemListFilter: String, Hashable, CaseIterable {
    case favorites = "Favorites"
}

enum ItemListEvent<ItemIdentifier: Hashable> {
    case deselectEverythingRenameMe
    case snapshot(NSDiffableDataSourceSnapshot<ItemListSection, ItemListCell<ItemIdentifier>>)
}

protocol ItemsListViewModel: AnyObject {
    associatedtype ItemIdentifier: Hashable

    var events: PassthroughSubject<ItemListEvent<ItemIdentifier>, Never> { get }
    var presentedAlert: PocketAlert? { get set }
    var selectionItem: SelectionItem { get }

    func fetch() throws
    func refresh(_ completion: (() -> ())?)
    
    func item(with cellID: ItemListCell<ItemIdentifier>) -> MyListItemPresenter?
    func item(with itemID: ItemIdentifier) -> MyListItemPresenter?
    func filterButton(with id: ItemListFilter) -> TopicChipPresenter
    func selectCell(with: ItemListCell<ItemIdentifier>)
    func shareItem(with: ItemListCell<ItemIdentifier>)
    
    func toggleFavorite(_ cell: ItemListCell<ItemIdentifier>)
    func archive(_ cell: ItemListCell<ItemIdentifier>)
    func delete(_ cell: ItemListCell<ItemIdentifier>)
    func trackImpression(_ cell: ItemListCell<ItemIdentifier>)
}


class MyListViewController<ViewModel: ItemsListViewModel>: UIViewController, UICollectionViewDelegate {
   
    private let model: ViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ItemListSection, ItemListCell<ViewModel.ItemIdentifier>>!

    init(model: ViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env -> NSCollectionLayoutSection? in
            guard let self = self,
                  let section = self.dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }

            switch section {
            case .filters:
                var totalWidth: CGFloat = 0
                let layoutItems = self.dataSource.snapshot(for: .filters).items.compactMap { cellID -> NSCollectionLayoutItem? in
                    guard case .filterButton(let filterID) = cellID else {
                        return nil
                    }

                    let model = self.model.filterButton(with: filterID)
                    let width = TopicChipCell.width(chip: model)

                    totalWidth += width
                    return NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .absolute(width),
                            heightDimension: .absolute(TopicChipCell.height)
                        )
                    )
                }

                let spacing: CGFloat = 12
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .absolute(totalWidth + ((CGFloat(layoutItems.count) - 1) * spacing)),
                        heightDimension: .absolute(TopicChipCell.height)
                    ),
                    subitems: layoutItems
                )
                group.interItemSpacing = .fixed(spacing)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous

                return section
            case .items:
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                config.backgroundColor = UIColor(.ui.white1)
                config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                    let archiveAction = UIContextualAction(
                        style: .normal,
                        title: "Archive"
                    ) { _, _, completion in
                        guard let cell = self.dataSource.itemIdentifier(for: indexPath) else {
                            completion(false)
                            return
                        }

                        model.archive(cell)
                        completion(true)
                    }
                    archiveAction.backgroundColor = UIColor(.ui.lapis1)

                    return UISwipeActionsConfiguration(actions: [archiveAction])
                }

                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            }
        }

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.handleRefresh()
            })
        )

        let filterButtonRegistration: UICollectionView.CellRegistration<TopicChipCell, ItemListFilter> = .init { [weak self] cell, indexPath, filterID in
            self?.configure(cell: cell, indexPath: indexPath, filterID: filterID)
        }

        let itemCellRegistration: UICollectionView.CellRegistration<MyListItemCell, ViewModel.ItemIdentifier> = .init { [weak self] cell, indexPath, objectID in
            self?.configure(cell: cell, indexPath: indexPath, objectID: objectID)
        }

        self.dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .filterButton(let filter):
                return collectionView.dequeueConfiguredReusableCell(using: filterButtonRegistration, for: indexPath, item: filter)
            case .item(let itemID):
                return collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: itemID)
            }
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

    private func configure(cell: MyListItemCell, indexPath: IndexPath, objectID: ViewModel.ItemIdentifier) {
        guard let item = model.item(with: objectID) else {
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

    private func configure(cell: TopicChipCell, indexPath: IndexPath, filterID: ItemListFilter) {
        cell.configure(model: model.filterButton(with: filterID))
    }

    private func handle(myListEvent event: ItemListEvent<ViewModel.ItemIdentifier>) {
        switch event {
        case .snapshot(let snapshot):
            dataSource.apply(snapshot, animatingDifferences: true)

        case .deselectEverythingRenameMe:
            deselectAll()
        }
    }

    private func deselectAll() {
        collectionView.indexPathsForSelectedItems?.forEach { selectedIndexPath in
            collectionView.deselectItem(at: selectedIndexPath, animated: false)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemID = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.selectCell(with: itemID)
        deselectAll()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.trackImpression(cell)
    }
}

extension MyListViewController: MyListItemCellDelegate {
    func myListItemCellDidTapFavoriteButton(_ itemCell: MyListItemCell) {
        withCell(for: itemCell, handler: model.toggleFavorite)
    }

    func myListItemCellDidTapShareButton(_ itemCell: MyListItemCell) {
        withCell(for: itemCell, handler: model.shareItem)
    }
    
    func myListItemCellDidTapArchiveButton(_ itemCell: MyListItemCell) {
        withCell(for: itemCell, handler: model.archive)
    }

    func myListItemCellDidTapDeleteButton(_ itemCell: MyListItemCell) {
        model.presentedAlert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: "No", style: .default) { [weak self] _ in
                    self?.model.presentedAlert = nil
                },
                UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                    self?.model.presentedAlert = nil
                    self?.withCell(for: itemCell, handler: self?.model.delete)
                }
            ],
            preferredAction: nil
        )
    }

    private func withCell(for itemCell: MyListItemCell, handler: ((ItemListCell<ViewModel.ItemIdentifier>) -> Void)?) {
        guard let indexPath = collectionView.indexPath(for: itemCell),
              let cell = dataSource.itemIdentifier(for: indexPath) else {
                  return
              }
        
        handler?(cell)
    }
}

extension MyListViewController: SelectableViewController {
    var selectionItem: SelectionItem {
        return model.selectionItem
    }
}
