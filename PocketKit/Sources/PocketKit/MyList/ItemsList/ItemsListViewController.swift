import UIKit
import Sync
import CoreData
import Combine
import Kingfisher


class ItemsListViewController<ViewModel: ItemsListViewModel>: UIViewController, UICollectionViewDelegate {
    private let model: ViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<ItemsListSection, ItemsListCell<ViewModel.ItemIdentifier>>!

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
                    guard case .item(let objectID) = self.dataSource.itemIdentifier(for: indexPath) else {
                        return nil
                    }

                    return UISwipeActionsConfiguration(actions: model.trailingSwipeActions(for: objectID))
                }

                return NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            case .offline:
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                config.backgroundColor = UIColor(.ui.white1)
                config.showsSeparators = false
                let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                
                // Update the section's contentInsets to center the offline cell
                // within the full size of the collection view
                let layoutHeight = env.container.contentSize.height
                let availableWidth = env.container.contentSize.width
                - ItemsListOfflineCell.Constants.padding
                - ItemsListOfflineCell.Constants.padding
                let offset = self.collectionView.safeAreaInsets.top
                section.contentInsets = NSDirectionalEdgeInsets(
                    top: (layoutHeight - ItemsListOfflineCell.height(fitting: availableWidth)) / 2 - offset,
                    leading: 0,
                    bottom: 0,
                    trailing: 0
                )
                
                return section
            case .nextPage:
                return NSCollectionLayoutSection(
                    group: .vertical(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(1)
                        ),
                        subitems: [
                            .init(
                                layoutSize: .init(
                                    widthDimension: .fractionalWidth(1),
                                    heightDimension: .fractionalHeight(1)
                                )
                            )
                        ]
                    )
                )
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

        let filterButtonRegistration: UICollectionView.CellRegistration<TopicChipCell, ItemsListFilter> = .init { [weak self] cell, indexPath, filterID in
            self?.configure(cell: cell, indexPath: indexPath, filterID: filterID)
        }

        let itemCellRegistration: UICollectionView.CellRegistration<ItemsListItemCell, ViewModel.ItemIdentifier> = .init { [weak self] cell, indexPath, objectID in
            self?.configure(cell: cell, indexPath: indexPath, objectID: objectID)
        }
        
        let offlineCellRegistration: UICollectionView.CellRegistration<ItemsListOfflineCell, String> = .init { cell, _, _ in
            cell.buttonAction = {
                model.fetch()
            }
        }

        let nextPageCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, String> = .init { cell, _, _ in
        }

        self.dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .filterButton(let filter):
                return collectionView.dequeueConfiguredReusableCell(using: filterButtonRegistration, for: indexPath, item: filter)
            case .item(let itemID):
                return collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: itemID)
            case .offline:
                return collectionView.dequeueConfiguredReusableCell(using: offlineCellRegistration, for: indexPath, item: "")
            case .nextPage:
                return collectionView.dequeueConfiguredReusableCell(using: nextPageCellRegistration, for: indexPath, item: "")
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
        view.backgroundColor = UIColor(.ui.white1)
        model.fetch()
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

    private func configure(cell: ItemsListItemCell, indexPath: IndexPath, objectID: ViewModel.ItemIdentifier) {
        guard let item = model.item(with: objectID) else {
            return
        }

        cell.backgroundConfiguration = .listPlainCell()
        cell.model = .init(
            attributedTitle: item.attributedTitle,
            attributedDetail: item.attributedDetail,
            thumbnailURL: item.thumbnailURL,
            shareAction: model.shareAction(for: objectID),
            favoriteAction: model.favoriteAction(for: objectID),
            overflowActions: model.overflowActions(for: objectID)
        )
    }

    private func configure(cell: TopicChipCell, indexPath: IndexPath, filterID: ItemsListFilter) {
        cell.configure(model: model.filterButton(with: filterID))
    }

    private func handle(myListEvent event: ItemsListEvent<ViewModel.ItemIdentifier>) {
        switch event {
        case .snapshot(let snapshot):
            dataSource.apply(snapshot, animatingDifferences: true)

        case .selectionCleared:
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
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.willDisplay(cell)
    }
}

extension ItemsListViewController: SelectableViewController {
    var selectionItem: SelectionItem {
        return model.selectionItem
    }
}
