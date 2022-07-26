import UIKit
import Sync
import CoreData


class HomeViewControllerSectionProvider {
    
    struct Constants {
        static let margin: CGFloat = 8
        static let sideMargin: CGFloat = 10
        static let carouselHeight: CGFloat = 146
        static let heroHeight: CGFloat = 380
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.margin, bottom: 0, trailing: Constants.margin)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.80), heightDimension: .absolute(Constants.carouselHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
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
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(Constants.heroHeight))
        let heroGroup = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [heroItem])
        
        let title = viewModel.slateName(with: slateID) ?? ""
        let sectionHeaderViewModel: SectionHeaderView.Model = .init(name: title, buttonTitle: "See All")
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(sectionHeaderViewModel.height(width: width - Constants.sideMargin*2))
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: Constants.margin, bottom: 0, trailing: Constants.margin)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.80), heightDimension: .absolute(Constants.carouselHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
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
