import UIKit
import Sync


class HomeViewControllerSectionProvider {
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

    func topicCarouselSection(slates: [Slate]?) -> NSCollectionLayoutSection? {
        guard let slates = slates, !slates.isEmpty else {
            return nil
        }

        var maxHeight: CGFloat = 0
        let items = slates.map { slate -> (width: CGFloat, item: NSCollectionLayoutItem) in
            let chip = TopicChipPresenter(title: slate.name, image: nil)
            let width = TopicChipCell.width(chip: chip)
            let height = TopicChipCell.height(chip: chip)
            maxHeight = max(height, maxHeight)

            return (width: width, item: NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(width),
                    heightDimension: .absolute(height)
                )
            ))
        }

        let spacing: CGFloat = 12
        let totalWidth = items.reduce(0) { $0 + $1.width } + (spacing * CGFloat(slates.count) - 1)
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(totalWidth),
                heightDimension: .absolute(maxHeight)
            ),
            subitems: items.map { $0.item }
        )
        group.interItemSpacing = .fixed(spacing)


        let section = NSCollectionLayoutSection(
            group: group
        )
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    
    func recentSavesSection(width: CGFloat) -> NSCollectionLayoutSection {
        let groupHeight: CGFloat = 152
        let margin: CGFloat = 8

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: margin, bottom: 0, trailing: margin)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.80), heightDimension: .absolute(groupHeight))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: margin, leading: margin, bottom: margin, trailing: margin)
        section.orthogonalScrollingBehavior = .continuous
        
        let sectionHeaderViewModel: SectionHeaderView.Model = .init(name: "Recent Saves", buttonTitle: "My List")
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(sectionHeaderViewModel.height(width: width))
                ),
                elementKind: SectionHeaderView.kind,
                alignment: .top
            )
        
        section.boundarySupplementaryItems = [headerItem]
        return section
    }

    func section(for slate: Slate?, in viewModel: HomeViewModel, width: CGFloat) -> NSCollectionLayoutSection? {
        let dividerHeight: CGFloat = 17
        let margin: CGFloat = 8
        let spacing: CGFloat = margin * 2

        let recommendations: [Recommendation] = slate?.recommendations?.compactMap { $0 as? Recommendation } ?? []

        guard let slate = slate, !recommendations.isEmpty else {
            return nil
        }

        guard let hero = viewModel.viewModel(for: recommendations[0].objectID) else {
            return nil
        }

        let heroHeight = RecommendationCell.fullHeight(viewModel: hero, availableWidth: width - spacing)
        let heroItem = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(heroHeight)
            )
        )

        let heroGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(heroHeight + dividerHeight)
            ),
            subitems: [heroItem]
        )

        heroGroup.supplementaryItems = [
            NSCollectionLayoutSupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(dividerHeight)
                ),
                elementKind: "divider",
                containerAnchor: NSCollectionLayoutAnchor(edges: .bottom)
            )
        ]

        let twoUp = twoUpGroup(slate: slate, viewModel: viewModel, width: width, spacing: spacing, dividerHeight: dividerHeight)

        let topLevelGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(heroHeight + dividerHeight + (twoUp.height + dividerHeight) * 2)
            ),
            subitems: [heroGroup, twoUp.group]
        )

        let section = NSCollectionLayoutSection(group: topLevelGroup)
        let sectionHeaderViewModel: SectionHeaderView.Model = .init(name: slate.name ?? "", buttonTitle: "See All")
        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(sectionHeaderViewModel.height(width: width))
                ),
                elementKind: SectionHeaderView.kind,
                alignment: .top
            )
        ]

        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: margin,
            bottom: 0,
            trailing: margin
        )

        return section
    }
}

extension HomeViewControllerSectionProvider {
    private func twoUpGroup(
        slate: Slate,
        viewModel: HomeViewModel,
        width: CGFloat,
        spacing: CGFloat,
        dividerHeight: CGFloat
    ) -> (group: NSCollectionLayoutGroup, height: CGFloat) {
        let recommendations: [Recommendation] = slate.recommendations?.compactMap { $0 as? Recommendation } ?? []

        guard recommendations.count > 1 else {
            return (
                group: NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(1),
                        heightDimension: .absolute(1)
                    ),
                    subitems: []
                ),
                height: 0
            )
        }

        let endIndex = recommendations.index(
            1,
            offsetBy: 3,
            limitedBy: recommendations.endIndex - 1
        ) ?? recommendations.endIndex - 1
        let recommendationsToShow = recommendations[1...endIndex]

        let miniCardHeight = recommendationsToShow.map { recommendation -> CGFloat in
            guard let viewModel = viewModel.viewModel(for: recommendation.objectID) else {
                return 0
            }

            return RecommendationCell.miniHeight(
                viewModel: viewModel,
                availableWidth: width - spacing
            )
        }.max() ?? 0

        let twoUpInner = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(miniCardHeight)
            ),
            subitem: NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .absolute(miniCardHeight)
                )
            ),
            count: 2
        )

        twoUpInner.supplementaryItems = [
            NSCollectionLayoutSupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(dividerHeight)
                ),
                elementKind: "twoup-divider",
                containerAnchor: NSCollectionLayoutAnchor(edges: .bottom),
                itemAnchor: NSCollectionLayoutAnchor(edges: .bottom)
            )
        ]

        let numberOfRows = Int((Float(recommendationsToShow.count) / 2).rounded(.up))
        return (
            group: NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute((miniCardHeight + dividerHeight) * 2)
                ),
                subitem: twoUpInner,
                count: numberOfRows
            ),
            height: miniCardHeight
        )
    }

}
