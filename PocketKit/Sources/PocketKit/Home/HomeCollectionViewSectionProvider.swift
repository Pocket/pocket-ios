import UIKit
import Sync
import CoreData

@MainActor
class HomeViewControllerSectionProvider {
    enum Constants {
        static let margin: CGFloat = Margins.thin.rawValue
        static let sideMargin: CGFloat = Margins.normal.rawValue
        static let iPadSideMargin: CGFloat = Margins.iPadNormal.rawValue
        static let spacing: CGFloat = 16
        static let sectionSpacing: CGFloat = 64
    }

    func loadingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(0.65)
            ),
            subitems: [item]
        )

        return NSCollectionLayoutSection(group: group)
    }

    func recentSavesSection(in viewModel: HomeViewModel, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let numberOfRecentSavesItems = viewModel.numberOfRecentSavesItem()
        guard numberOfRecentSavesItems > 0 else { return .empty() }

        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let itemWidthPercentage: CGFloat
        let sideMargin: CGFloat
        if env.traitCollection.shouldUseWideLayout() {
            sideMargin = Constants.iPadSideMargin
            itemWidthPercentage = 2/5
        } else {
            sideMargin = Constants.sideMargin
            itemWidthPercentage = 0.8
        }

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(itemWidthPercentage * Double(numberOfRecentSavesItems)),
                heightDimension: .absolute(StyleConstants.groupHeight)
            ),
            subitem: item,
            count: numberOfRecentSavesItems
        )
        group.interItemSpacing = .fixed(16)

        let sectionHeaderViewModel = viewModel.sectionHeaderViewModel(for: .recentSaves)
        let width = env.container.effectiveContentSize.width
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(
                    sectionHeaderViewModel?.height(
                        width: width - Constants.sideMargin * 2
                    ) ?? 1
                )
            ),
            elementKind: SectionHeaderView.kind,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [headerItem]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.margin,
            leading: sideMargin,
            bottom: Constants.sectionSpacing,
            trailing: sideMargin
        )
        return section
    }

    func heroSection(for slateID: NSManagedObjectID, in viewModel: HomeViewModel, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let heroItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let heroItem = NSCollectionLayoutItem(layoutSize: heroItemSize)

        let slate = viewModel.slateModel(for: slateID)
        let recommendations: [Recommendation] = slate?.recommendations?.compactMap { $0 as? Recommendation } ?? []

        guard !recommendations.isEmpty,
              let hero = viewModel.recommendationHeroViewModel(for: recommendations[0].objectID) else {
            return nil
        }

        let width = env.container.effectiveContentSize.width
        let heroHeight: CGFloat
        let sideMargin: CGFloat
        if env.traitCollection.shouldUseWideLayout() {
            sideMargin = Constants.iPadSideMargin
            heroHeight = width * 0.28
        } else {
            sideMargin = Constants.sideMargin
            heroHeight = RecommendationCell.fullHeight(viewModel: hero, availableWidth: width - (Constants.sideMargin * 2))
        }

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(heroHeight))
        let heroGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [heroItem])
        let sectionHeaderViewModel = viewModel.sectionHeaderViewModel(for: .slateHero(slateID))

        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(sectionHeaderViewModel?.height(width: width - Constants.sideMargin * 2) ?? 0)
            ),
            elementKind: SectionHeaderView.kind,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: heroGroup)
        section.boundarySupplementaryItems = [headerItem]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.margin,
            leading: sideMargin,
            bottom: Constants.margin,
            trailing: sideMargin
        )
        return section
    }

    func additionalRecommendationsSection(for slateID: NSManagedObjectID, in viewModel: HomeViewModel, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        if env.traitCollection.shouldUseWideLayout() {
            return recommendationCellGridSection(for: slateID, in: viewModel, env: env)
        } else {
            return carouselSection(for: slateID, in: viewModel, env: env)
        }
    }

    private func carouselSection(for slateID: NSManagedObjectID, in viewModel: HomeViewModel, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let numberOfCarouselItems = viewModel.numberOfCarouselItemsForSlate(with: slateID)
        guard numberOfCarouselItems > 0 else {
            return .empty()
        }

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8*Double(numberOfCarouselItems)), heightDimension: .absolute(StyleConstants.groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfCarouselItems)
        group.interItemSpacing = .fixed(16)

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.margin,
            leading: Constants.sideMargin,
            bottom: Constants.sectionSpacing,
            trailing: Constants.sideMargin
        )
        return section
    }

    private func recommendationCellGridSection(for slateID: NSManagedObjectID, in viewModel: HomeViewModel, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let numberOfCarouselItems = viewModel.numberOfCarouselItemsForSlate(with: slateID)
        guard numberOfCarouselItems > 0 else {
            return .empty()
        }

        let numberOfGroups = (CGFloat(numberOfCarouselItems) / 2).rounded(.up)
        let groups = (0..<Int(numberOfGroups)).map { _ -> NSCollectionLayoutGroup in
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(StyleConstants.groupHeight)
                ),
                subitem: .init(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1)
                    )
                ),
                count: 2
            )
            group.interItemSpacing = .fixed(Constants.spacing)
            return group
        }

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(
                    numberOfGroups * StyleConstants.groupHeight +
                    (Constants.spacing * (numberOfGroups - 1))
                )
            ),
            subitems: groups
        )
        group.interItemSpacing = .fixed(Constants.spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.margin,
            leading: Constants.iPadSideMargin,
            bottom: Constants.sectionSpacing,
            trailing: Constants.iPadSideMargin
        )

        return section
    }
}

extension HomeViewControllerSectionProvider {
    func offlineSection(environment: NSCollectionLayoutEnvironment, withRecentSaves: Bool) -> NSCollectionLayoutSection {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = UIColor(.ui.white1)
        config.showsSeparators = false
        let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)

        let availableWidth = environment.container.contentSize.width
        - ItemsListOfflineCell.Constants.padding
        - ItemsListOfflineCell.Constants.padding

        if !withRecentSaves {
            section.contentInsets = NSDirectionalEdgeInsets(
                top: ItemsListOfflineCell.height(fitting: availableWidth) / 4, // Insets the top so "No Internet Connection" is centered
                leading: 0,
                bottom: 0,
                trailing: 0
            )
        }

        return section
    }
}
