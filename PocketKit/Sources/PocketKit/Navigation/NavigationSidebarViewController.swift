import UIKit
import Combine
import Textile
import Analytics

private extension Style {
    static let title: Style = .header.sansSerif.h8
}

class NavigationSidebarViewController: UIViewController {
    private lazy var layout: UICollectionViewLayout = {
        UICollectionViewCompositionalLayout { index, env in
            let baseCellHeight = UIFontMetrics.default.scaledValue(for: 40)
            let numberOfItems = MainViewModel.AppSection.allCases.count

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(baseCellHeight * CGFloat(numberOfItems))
                ),
                subitem: NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(baseCellHeight)
                    )
                ),
                count: numberOfItems
            )
            group.interItemSpacing = .fixed(6)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 27,
                leading: 27,
                bottom: 0,
                trailing: 18
            )

            section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(33)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
            ]

            return section
        }
    }()

    private static let snapshot: NSDiffableDataSourceSnapshot<String, MainViewModel.AppSection> = {
        var snapshot = NSDiffableDataSourceSnapshot<String, MainViewModel.AppSection>()
        let section = "app-section"
        snapshot.appendSections([section])
        snapshot.appendItems(MainViewModel.AppSection.allCases, toSection: section)
        return snapshot
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<String, MainViewModel.AppSection> = {
        let registration = UICollectionView.CellRegistration<NavigationSidebarCell, MainViewModel.AppSection> { [weak self] (cell, indexPath, appSection) in
            self?.configure(cell, appSection: appSection)
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<NavigationHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { (headerView, _, _) in
            // no op
        }

        let dataSource = UICollectionViewDiffableDataSource<String, MainViewModel.AppSection>(
            collectionView: collectionView
        ) { (collectionView, indexPath, appSection) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: appSection)
        }

        dataSource.supplementaryViewProvider = { (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }

        return dataSource
    }()

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )
    private let model: MainViewModel
    private let tracker: Tracker
    private var subscriptions: Set<AnyCancellable> = []

    init(model: MainViewModel, tracker: Tracker) {
        self.model = model
        self.tracker = tracker
        super.init(nibName: nil, bundle: nil)

        self.title = L10n.pocket

        collectionView.contentInset = UIEdgeInsets(top: 21, left: 0, bottom: 0, right: 0)
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        dataSource.apply(Self.snapshot)

        model.$selectedSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appSection in
                self?.select(appSection)
            }
            .store(in: &subscriptions)
    }

    override func loadView() {
        view = collectionView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let event = ImpressionEvent(component: .screen, requirement: .instant)
        tracker.track(event: event, nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    private func configure(_ cell: NavigationSidebarCell, appSection: MainViewModel.AppSection) {
        let cellModel = model.navigationSidebarCellViewModel(for: appSection)
        cell.configure(model: cellModel)
    }

    private func select(_ appSection: MainViewModel.AppSection) {
        collectionView.reloadData()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory {
            layout.invalidateLayout()
        }
    }
}

extension NavigationSidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.selectedSection = MainViewModel.AppSection.allCases[indexPath.item]
    }
}
