import UIKit


extension NSCollectionLayoutSection {
    static func empty() -> NSCollectionLayoutSection {
        return NSCollectionLayoutSection(
            group: NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
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
        )
    }
}
