// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import CoreData
import Combine
import Kingfisher
import Textile
import SafariServices

class ItemsListViewController<ViewModel: ItemsListViewModel>: UIViewController, UICollectionViewDelegate, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout {
    private let model: ViewModel
    private var subscriptions: [AnyCancellable] = []
    private var collectionView: UICollectionView!
    private var progressView: UIProgressView!
    private var dataSource: UICollectionViewDiffableDataSource<ItemsListSection, ItemsListCell<ViewModel.ItemIdentifier>>!
    private var itemSectionLayout: NSCollectionLayoutSection!

    init(model: ViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)

        self.collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: collectionViewLayout()
        )

        collectionView.delegate = self
        collectionView.refreshControl = UIRefreshControl(
            frame: .zero,
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.handleRefresh()
            })
        )

        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = UIColor(.ui.teal2)
        progressView.trackTintColor = UIColor(.ui.teal6)
        progressView.isHidden = false

        setupDataSourceFilters()

        model.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            self?.handle(savesEvent: event)
        }.store(in: &subscriptions)

        model.snapshot.receive(on: DispatchQueue.main).sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }.store(in: &subscriptions)

        model.initialDownloadState.receive(on: DispatchQueue.main).sink { [weak self] initialDownloadState in
            self?.updateProgressBar(downloadState: initialDownloadState)
        }.store(in: &subscriptions)

        collectionView.prefetchDataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(.ui.white1)
        model.fetch()
    }

    override func loadView() {
        view = collectionView
    }

    override func viewWillLayoutSubviews() {
        if let itemSectionLayout {
            setContentInsetReferecnce(for: itemSectionLayout)
        }
    }

    private func setContentInsetReferecnce(for section: NSCollectionLayoutSection) {
        if self.traitCollection.horizontalSizeClass == .regular {
            section.contentInsetsReference = .readableContent
        } else {
            section.contentInsetsReference = .automatic
        }
    }

    /// Whether or not we should show the progress bar.
    /// We specifically add or remove it instead of hide/show it because our tests will not execute actions on the list when the progress bar is there, but hidden.
    /// - Parameter shouldShow: Whether or not to show the progress barå
    func shouldShowProgressBar(shouldShow: Bool) {
        if shouldShow {
            guard !self.view.subviews.contains(progressView) else {
                // Progress bar is already in the view, so return
                return
            }
            view.addSubview(progressView)
            progressView.isHidden = false
            progressView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                progressView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                progressView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                progressView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
            ])
        } else {
            progressView.isHidden = true
            progressView.removeFromSuperview()
        }
    }

    func updateProgressBar(downloadState: InitialDownloadState) {
        switch downloadState {
        case .unknown:
            shouldShowProgressBar(shouldShow: false)
        case .started:
            progressView.setProgress(0, animated: true)
            shouldShowProgressBar(shouldShow: true)
        case .paginating(totalCount: _, currentPercentProgress: let progess):
            progressView.setProgress(progess, animated: true)
            shouldShowProgressBar(shouldShow: true)
        case .completed:
            progressView.setProgress(100, animated: true)
            shouldShowProgressBar(shouldShow: false)
        }
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

    // MARK: - Setup Views

    private func setupDataSourceFilters() {
        let filterButtonRegistration: UICollectionView.CellRegistration<TopicChipCell, ItemsListFilter> = .init { [weak self] cell, indexPath, filterID in
            self?.configure(cell: cell, indexPath: indexPath, filterID: filterID)
        }

        let tagButtonRegistration: UICollectionView.CellRegistration<SelectedTagChipCell, String> = .init { [weak self] cell, _, name in
            self?.configure(cell: cell, name: name)
        }

        let itemCellRegistration: UICollectionView.CellRegistration<ItemsListItemCell, ViewModel.ItemIdentifier> = .init { [weak self] cell, indexPath, objectID in
            self?.configure(cell: cell, indexPath: indexPath, objectID: objectID)
        }

        let emptyCellRegistration: UICollectionView.CellRegistration<EmptyStateCollectionViewCell, String> = .init { [weak self] cell, _, _ in
            self?.configure(cell: cell)
        }

        let offlineCellRegistration: UICollectionView.CellRegistration<ItemsListOfflineCell, String> = .init { cell, _, _ in
        }

        let placeholderCellRegistration: UICollectionView.CellRegistration<ItemSkeletonCell, Int> = .init { cell, indexPath, itemIndex in
            // no op
        }

        self.dataSource = .init(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .filterButton(let filter):
                return collectionView.dequeueConfiguredReusableCell(using: filterButtonRegistration, for: indexPath, item: filter)
            case .tag(let name):
                return collectionView.dequeueConfiguredReusableCell(using: tagButtonRegistration, for: indexPath, item: name)
            case .item(let itemID):
                return collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: itemID)
            case .emptyState:
                return collectionView.dequeueConfiguredReusableCell(using: emptyCellRegistration, for: indexPath, item: "")
            case .offline:
                return collectionView.dequeueConfiguredReusableCell(using: offlineCellRegistration, for: indexPath, item: "")
            case .placeholder(let index):
                return collectionView.dequeueConfiguredReusableCell(using: placeholderCellRegistration, for: indexPath, item: index)
            }
        }
    }

    private func collectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, env -> NSCollectionLayoutSection? in
            guard let self = self,
                  let section = self.dataSource.sectionIdentifier(for: sectionIndex) else {
                return nil
            }

            switch section {
            case .filters:
                var totalWidth: CGFloat = 0
                var maxHeight: CGFloat = 0
                let layoutItems = self.dataSource.snapshot(for: .filters).items.compactMap { cellID -> NSCollectionLayoutItem? in
                    guard case .filterButton(let filterID) = cellID else {
                        return nil
                    }

                    let model = self.model.filterButton(with: filterID)
                    let width = TopicChipCell.width(chip: model)
                    let height = TopicChipCell.height(chip: model)
                    maxHeight = max(height, maxHeight)

                    totalWidth += width
                    return NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .absolute(width),
                            heightDimension: .absolute(height)
                        )
                    )
                }

                let spacing: CGFloat = 12
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .absolute(totalWidth + ((CGFloat(layoutItems.count) - 1) * spacing)),
                        heightDimension: .absolute(maxHeight)
                    ),
                    subitems: layoutItems
                )
                group.interItemSpacing = .fixed(spacing)

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous

                return section
            case .tags:
                guard case .tag(let name) = self.dataSource.snapshot(for: .tags).items.first else { return nil }
                let selectedTagModel = self.model.tagModel(with: name)
                let width = SelectedTagChipCell.width(model: selectedTagModel)
                let height = SelectedTagChipCell.height(model: selectedTagModel)
                let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height)))

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                return section
            case .items:
                var config = UICollectionLayoutListConfiguration(appearance: .plain)
                config.backgroundColor = UIColor(.ui.white1)
                config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                    guard case .item(let objectID) = self.dataSource.itemIdentifier(for: indexPath) else {
                        return nil
                    }

                    let actions = self.model.trailingSwipeActions(for: objectID)
                    .compactMap(UIContextualAction.init)

                    return UISwipeActionsConfiguration(actions: actions)
                }

                itemSectionLayout = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
                setContentInsetReferecnce(for: itemSectionLayout)

                var contentInsets = itemSectionLayout.contentInsets
                    contentInsets.leading = 0
                    contentInsets.trailing = 0
                    itemSectionLayout.contentInsets = contentInsets

                return itemSectionLayout
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
            case .emptyState:
                let section = NSCollectionLayoutSection(
                    group: .vertical(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(0.65)
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
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
                return section
            }
        }
    }

    // MARK: - Cell Configuration

    private func configure(cell: ItemsListItemCell, indexPath: IndexPath, objectID: ViewModel.ItemIdentifier) {
        cell.backgroundConfiguration = .listPlainCell()

        guard let presenter = model.presenter(for: objectID) else {
            cell.model = .init(
                attributedTitle: NSAttributedString(string: ""),
                attributedDetail: NSAttributedString(string: ""),
                attributedTags: nil,
                attributedTagCount: nil,
                thumbnailURL: nil,
                shareAction: nil,
                favoriteAction: nil,
                overflowActions: [],
                filterByTagAction: nil,
                trackOverflow: nil,
                swiftUITrackOverflow: nil
            )

            return
        }

        cell.model = .init(
            attributedTitle: presenter.attributedTitle,
            attributedDetail: presenter.attributedDetail,
            attributedTags: presenter.attributedTags,
            attributedTagCount: presenter.attributedTagCount,
            thumbnailURL: presenter.thumbnailURL,
            shareAction: model.shareAction(for: objectID),
            favoriteAction: model.favoriteAction(for: objectID),
            overflowActions: model.overflowActions(for: objectID),
            filterByTagAction: model.filterByTagAction(),
            trackOverflow: model.trackOverflow(for: objectID),
            swiftUITrackOverflow: model.swiftUITrackOverflow(for: objectID)
        )
    }

    private func configure(cell: TopicChipCell, indexPath: IndexPath, filterID: ItemsListFilter) {
        cell.configure(model: model.filterButton(with: filterID))
    }

    private func configure(cell: SelectedTagChipCell, name: String) {
        cell.configure(model: SelectedTagChipCell.Model(
            name: name,
            closeAction: UIAction(handler: { [weak self] _ in
                self?.model.selectCell(with: .filterButton(.all), sender: nil)
            })
        ))
    }

    private func configure(cell: EmptyStateCollectionViewCell) {
        guard let viewModel = model.emptyState else {
            return
        }
        cell.configure(parent: self, viewModel)
    }

    private func handle(savesEvent event: ItemsListEvent<ViewModel.ItemIdentifier>) {
        switch event {
        case .selectionCleared:
            deselectAll()
        case .networkStatusUpdated:
            let reloads = collectionView.indexPathsForVisibleItems
                .compactMap { dataSource.itemIdentifier(for: $0) }
            model.reloadSnapshot(for: reloads)
        }
    }

    private func deselectAll() {
        collectionView.indexPathsForSelectedItems?.forEach { selectedIndexPath in
            collectionView.deselectItem(at: selectedIndexPath, animated: false)
        }
    }

    // MARK: - CollectionView Delegate Methods

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let itemID = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.selectCell(with: itemID, sender: collectionView.cellForItem(at: indexPath) as Any)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.willDisplay(cell)
    }

    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }

        return model.shouldSelectCell(with: cell)
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        model.prefetch(itemsAt: indexPaths)
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let item = dataSource.itemIdentifier(for: indexPath), let (viewModel, showInWebView) = model.preview(for: item) else {
            return nil
        }

        return UIContextMenuConfiguration {
            if showInWebView {
                guard let url = URL(percentEncoding: viewModel.url) else { return UIViewController() }
                return SFSafariViewController(url: url)
            } else {
                return ReadableViewController(readable: viewModel, readerSettings: ReaderSettings(userDefaults: .standard))
            }
        } actionProvider: { _ in
            return UIMenu(children: [
                UIAction(title: "Edit") { [weak self] _ in
                    self?.model.beginBulkEdit()
                }
            ])
        }
    }
}

extension ItemsListViewController: SelectableViewController {
    var selectionItem: SelectionItem {
        return model.selectionItem
    }

    func didBecomeSelected(by parent: SavesContainerViewController) {
        // Fixes an issue where the navigation bar state could be out-of-sync
        // with the expected state based on the current visible
        // collection view's content offset after toggling list selection.
        collectionView.contentOffset.y += 1
        collectionView.contentOffset.y -= 1
    }
}
