// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension NSCollectionLayoutSection {
    static func empty() -> NSCollectionLayoutSection {
        return NSCollectionLayoutSection(
            group: NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0),
                    heightDimension: .fractionalHeight(0)
                ),
                subitems: [
                    NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(0),
                            heightDimension: .fractionalHeight(0)
                        )
                    )
                ]
            )
        )
    }
}
