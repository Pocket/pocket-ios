// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Textile

class ItemSkeletonCell: UICollectionViewListCell {
    private let actionsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .itemSkeletonActions)

        return imageView
    }()

    private let tagsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .itemSkeletonTags)

        return imageView
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .itemSkeletonThumbnail)

        return imageView
    }()

    private let titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .itemSkeletonTitle)

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        accessibilityIdentifier = "saves-item-skeleton"

        contentView.backgroundColor = UIColor(.ui.white1)
        contentView.addSubview(actionsImageView)
        contentView.addSubview(tagsImageView)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleImageView)

        actionsImageView.translatesAutoresizingMaskIntoConstraints = false
        tagsImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        titleImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.layoutMargins = .init(top: 12, left: 20, bottom: 12, right: 20)

        NSLayoutConstraint.activate([
            titleImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            titleImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleImageView.trailingAnchor.constraint(lessThanOrEqualTo: thumbnailImageView.leadingAnchor, constant: -32),
            titleImageView.heightAnchor.constraint(equalTo: thumbnailImageView.heightAnchor),

            thumbnailImageView.topAnchor.constraint(equalTo: titleImageView.topAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: ItemsListItemCell.Constants.thumbnailSize.width),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: ItemsListItemCell.Constants.thumbnailSize.height),

            tagsImageView.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 12),
            tagsImageView.leadingAnchor.constraint(equalTo: titleImageView.leadingAnchor),

            actionsImageView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 10),
            actionsImageView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            actionsImageView.leadingAnchor.constraint(greaterThanOrEqualTo: tagsImageView.trailingAnchor, constant: 10),

            // Determine height of cell based on content
            // Using `.defaultHigh` priority to avoid conflict with default constraints
            actionsImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
                .with(priority: .defaultHigh),
            tagsImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
                .with(priority: .defaultHigh),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
