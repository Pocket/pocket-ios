import UIKit


enum MyListLayoutBuilder {
    static func buildLayout(model: MyListViewModel?, env: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        guard let items = model?.items else {
            return .empty()
        }

        var totalHeight: CGFloat = 0
        let layoutItems = items.map { item -> NSCollectionLayoutItem in
            let availableWidth = env.container.effectiveContentSize.width
            let size = cellSize(for: item, availableWidth: availableWidth)
            totalHeight += size.height

            return NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(size.height)
                )
            )
        }

        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(totalHeight)
            ),
            subitems: layoutItems
        )

        return NSCollectionLayoutSection(group: group)
    }

    private static func cellSize(for item: MyListItemViewModel, availableWidth: CGFloat) -> CGSize {
        var availableTextWidth = availableWidth
        - MyListItemCell.Constants.margins.left
        - MyListItemCell.Constants.margins.right

        if item.thumbnailURL != nil {
            availableTextWidth -= MyListItemCell.Constants.thumbnailSize.width
            availableTextWidth -= MyListItemCell.Constants.mainStackSpacing
        }

        let titleHeight = RecommendationCell.height(
            of: item.attributedTitleForMeasurement,
            width: availableTextWidth,
            numberOfLines: MyListItemCell.Constants.maxTitleLines
        )

        let detailHeight = RecommendationCell.height(
            of: item.attributedDetailForMeasurement,
            width: availableTextWidth,
            numberOfLines: MyListItemCell.Constants.maxDetailLines
        )

        let textStackHeight = titleHeight
        + MyListItemCell.Constants.textStackSpacing
        + detailHeight

        let cellHeight = MyListItemCell.Constants.margins.top
        + max(textStackHeight, MyListItemCell.Constants.thumbnailSize.height)
        + MyListItemCell.Constants.topLevelStackSpacing
        + MyListItemCell.Constants.actionButtonHeight
        + MyListItemCell.Constants.margins.bottom

        return CGSize(
            width: availableWidth,
            height: cellHeight
        )
    }
}
