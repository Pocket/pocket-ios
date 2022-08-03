import UIKit
import Sync
import CoreData


class HomeViewControllerSectionProvider {
    struct Constants {
        static let margin: CGFloat = Margins.thin.rawValue
        static let sideMargin: CGFloat = Margins.normal.rawValue
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

    func recentSavesSection(in viewModel: HomeViewModel, width: CGFloat) -> NSCollectionLayoutSection? {
        let numberOfRecentSavesItems = viewModel.numberOfRecentSavesItem()
        guard numberOfRecentSavesItems > 0 else { return .empty() }
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8*Double(numberOfRecentSavesItems)), heightDimension: .absolute(StyleConstants.groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: numberOfRecentSavesItems)
        group.interItemSpacing = .fixed(16)

        let sectionHeaderViewModel: SectionHeaderView.Model = .init(name: "Recent Saves", buttonTitle: "My List")
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(sectionHeaderViewModel.height(width: width - Constants.sideMargin*2))
            ),
            elementKind: SectionHeaderView.kind,
            alignment: .top
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [headerItem]
        section.contentInsets = NSDirectionalEdgeInsets(
            top: Constants.margin,
            leading: Constants.sideMargin,
            bottom: Constants.sectionSpacing,
            trailing: Constants.sideMargin
        )
        return section
    }
    
    func heroSection(for slateID: NSManagedObjectID, in viewModel: HomeViewModel, width: CGFloat) -> NSCollectionLayoutSection? {
        let heroItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1))
        let heroItem = NSCollectionLayoutItem(layoutSize: heroItemSize)
        
        let slate = viewModel.slateModel(for: slateID)
        let recommendations: [Recommendation] = slate?.recommendations?.compactMap { $0 as? Recommendation } ?? []
        
        guard !recommendations.isEmpty,
              let hero = viewModel.recommendationHeroViewModel(for: recommendations[0].objectID) else {
            return nil
        }
        
        let heroHeight = RecommendationCell.fullHeight(viewModel: hero, availableWidth: width - (Constants.sideMargin * 2))
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
            leading: Constants.sideMargin,
            bottom: Constants.margin,
            trailing: Constants.sideMargin
        )
        return section
    }

    
    func carouselSection(for slateID: NSManagedObjectID, in viewModel: HomeViewModel, width: CGFloat) -> NSCollectionLayoutSection? {
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
}
