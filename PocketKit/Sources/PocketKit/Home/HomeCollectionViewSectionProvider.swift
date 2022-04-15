import UIKit
import Sync


class HomeViewControllerSectionProvider {
    func topicCarouselSection(slates: [UnmanagedSlate]?) -> NSCollectionLayoutSection {
        guard let slates = slates, !slates.isEmpty else {
            return NSCollectionLayoutSection(
                group: .horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(0),
                        heightDimension: .absolute(0)
                    ),
                    subitems: []
                )
            )
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

    func section(for slate: UnmanagedSlate?, width: CGFloat) -> NSCollectionLayoutSection {
        let dividerHeight: CGFloat = 17
        let margin: CGFloat = 8
        let spacing: CGFloat = margin * 2

        guard let slate = slate, !slate.recommendations.isEmpty else {
            return NSCollectionLayoutSection(
                group: .vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(0),
                        heightDimension: .absolute(0)
                    ),
                    subitems: []
                )
            )
        }

        let hero = RecommendationPresenter(recommendation: slate.recommendations[0])
        let heroHeight = RecommendationCell.fullHeight(width: width - spacing, recommendation: hero)
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

        let twoUp = twoUpGroup(slate: slate, width: width, spacing: spacing, dividerHeight: dividerHeight)

        let topLevelGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(heroHeight + dividerHeight + (twoUp.height + dividerHeight) * 2)
            ),
            subitems: [heroGroup, twoUp.group]
        )

        let section = NSCollectionLayoutSection(group: topLevelGroup)
        let slatePresenter = SlateHeaderPresenter(slate: slate)

        section.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(SlateHeaderView.height(width: width, slate: slatePresenter))
                ),
                elementKind: SlateHeaderView.kind,
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

    func twoUpGroup(
        slate: UnmanagedSlate,
        width: CGFloat,
        spacing: CGFloat,
        dividerHeight: CGFloat
    ) -> (group: NSCollectionLayoutGroup, height: CGFloat) {
        guard slate.recommendations.count > 1 else {
            return (
                group: NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(0),
                        heightDimension: .absolute(0)
                    ),
                    subitems: []
                ),
                height: 0
            )
        }

        let endIndex = slate.recommendations.index(
            1,
            offsetBy: 3,
            limitedBy: slate.recommendations.endIndex - 1
        ) ?? slate.recommendations.endIndex - 1
        let recommendationsToShow = slate.recommendations[1...endIndex]

        let miniCardHeight = recommendationsToShow.map {
            RecommendationCell.miniHeight(
                width: width - spacing,
                recommendation: RecommendationPresenter(recommendation: $0)
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
