// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Analytics
import Combine
import Lottie
import Textile
import Localization

// Main view for native collections which includes metadata on a collection and list of stories
class CollectionViewController: UIViewController {
    private lazy var getArchiveButton: UIBarButtonItem = {
        let archiveNavButton = UIBarButtonItem(
            image: UIImage(asset: .archive),
            style: .plain,
            target: self,
            action: #selector(archive)
        )

        archiveNavButton.accessibilityIdentifier = "archiveNavButton"
        return archiveNavButton
    }()

    private lazy var getSavesButton: UIBarButtonItem = {
        let savesNavButton = UIBarButtonItem(
            image: UIImage(asset: .save),
            style: .plain,
            target: self,
            action: #selector(moveToSaves)
        )

        savesNavButton.accessibilityIdentifier = "savesNavButton"
        return savesNavButton
    }()

    private lazy var moreButtonItem: UIBarButtonItem = {
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            menu: nil
        )

        moreButton.accessibilityIdentifier = "moreButton"
        return moreButton
    }()

    private lazy var layoutConfiguration = UICollectionViewCompositionalLayout { [weak self] index, env in
        return self?.section(for: index, environment: env)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<CollectionViewModel.Section, CollectionViewModel.Cell> = {
        UICollectionViewDiffableDataSource<CollectionViewModel.Section, CollectionViewModel.Cell>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, viewModelCell) -> UICollectionViewCell? in
            return self?.cell(for: viewModelCell, at: indexPath)
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutConfiguration)
        return collectionView
    }()

    private let sectionProvider: GridSectionLayoutProvider
    private var metadata: CollectionMetadata?
    private var subscriptions: [AnyCancellable] = []

    private let model: CollectionViewModel

    init(
        model: CollectionViewModel
    ) {
        self.model = model

        sectionProvider = GridSectionLayoutProvider()

        super.init(nibName: nil, bundle: nil)

        view.accessibilityIdentifier = "collection-view"
        title = nil
        navigationItem.largeTitleDisplayMode = .never
        hidesBottomBarWhenPushed = true

        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        collectionView.register(cellClass: LoadingCell.self)
        collectionView.register(cellClass: EmptyCell.self)
        collectionView.register(cellClass: CollectionMetadataCell.self)
        collectionView.register(cellClass: HomeItemCell.self)
        collectionView.register(cellClass: EmptyStateCollectionViewCell.self)

        model.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            }
            .store(in: &subscriptions)

        model.$actions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] actions in
                self?.buildOverflowMenu(from: actions)
            }
            .store(in: &subscriptions)

        model.$metadata
            .receive(on: DispatchQueue.main)
            .sink { [weak self] metadata in
                self?.metadata = metadata
            }
            .store(in: &subscriptions)

        model.$isArchived
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink { [weak self] isArchived in
                self?.setBarbuttonItems(isArchived: isArchived)
            }
            .store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    private func setBarbuttonItems(isArchived: Bool?) {
        var button = getSavesButton
        if let isArchived {
            button = isArchived ? getSavesButton : getArchiveButton
        }
        navigationItem.rightBarButtonItems = [moreButtonItem, button]
    }

    func buildOverflowMenu(from actions: [ItemAction]) {
        moreButtonItem.menu = UIMenu(
            image: nil,
            identifier: nil,
            options: [],
            children: [
                UIDeferredMenuElement.uncached { [weak self] completion in
                    self?.model.trackOverflow()
                    completion(actions.compactMap(UIAction.init))
                }
            ]
        )
    }

    @objc
    private func archive() {
        model.archive()
    }

    @objc
    private func moveToSaves() {
        model.moveToSaves { [weak self] success in
            if success,
               let items = self?.navigationItem.rightBarButtonItems,
               let getSavesButton = self?.getSavesButton,
               let index = items.firstIndex(of: getSavesButton),
               let archiveButton = self?.getArchiveButton {
                self?.navigationItem.rightBarButtonItems?[index] = archiveButton
            }
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        model.fetch()
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if isMovingFromParent {
            model.deallocate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension CollectionViewController {
    enum Constants {
        /// Height that centers the error section so that it appears approximately in the middle
        static let errorSectionHeight: CGFloat = 0.65
        static let errorSectionInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }

    func section(for index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let section = self.dataSource.sectionIdentifier(for: index)
        switch section {
        case .loading:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.8)
                ),
                subitems: [item]
            )
            return NSCollectionLayoutSection(group: group)
        case .collectionHeader:
            let availableItemWidth = environment.container.effectiveContentSize.width
            let margin: CGFloat = environment.traitCollection.shouldUseWideLayout() ? Margins.iPadNormal.rawValue : Margins.normal.rawValue
            let height = metadata?.size(for: availableItemWidth - (margin * 2)).height ?? 1
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(height)
                ),
                subitems: [
                    NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                ]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: margin,
                bottom: 0,
                trailing: margin
            )

            return section
        case .collection(let collection):
            let stories = collection.stories?.compactMap { $0 as? CollectionStory } ?? []
            let viewModels = stories.compactMap { model.storyViewModel(for: $0) }

            return sectionProvider.gridSection(for: viewModels, with: environment, and: view)
        case .error:
            let section = NSCollectionLayoutSection(
                group: .vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalHeight(Constants.errorSectionHeight)
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
            section.contentInsets = Constants.errorSectionInsets
            return section
        default:
            return .empty()
        }
    }

    func cell(
        for viewModelCell: CollectionViewModel.Cell,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch viewModelCell {
        case .loading:
            let cell: LoadingCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case .empty:
            let cell: EmptyCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case .collectionHeader:
            let metaCell: CollectionMetadataCell = collectionView.dequeueCell(for: indexPath)
            metaCell.configure(model: .init(
                byline: metadata?.attributedByline,
                itemCount: metadata?.attributedCount,
                title: metadata?.attributedTitle,
                intro: metadata?.attributedIntro
            ))
            return metaCell
        case .story(let story):
            let cell: HomeItemCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(model: story)
            return cell
        case .error:
            let cell: EmptyStateCollectionViewCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(viewModel: model.errorEmptyState)
            return cell
        }
    }
}

extension CollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.select(cell: cell)
    }
}
