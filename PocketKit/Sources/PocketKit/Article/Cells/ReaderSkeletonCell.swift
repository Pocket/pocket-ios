// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class ReaderSkeletonCell: UICollectionViewCell {
    private let bylineImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .readerSkeleton.byline)
        return imageView
    }()

    private let headImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .readerSkeleton.head)
        return imageView
    }()

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .readerSkeleton.thumbnail)
        return imageView
    }()

    private let subheadImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .readerSkeleton.subhead)
        return imageView
    }()

    private let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor(.ui.skeletonCellImageBackground)
        imageView.image = UIImage(asset: .readerSkeleton.content)
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor(.ui.white1)

        contentView.addSubview(bylineImageView)
        contentView.addSubview(headImageView)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(subheadImageView)
        contentView.addSubview(contentImageView)

        contentView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        bylineImageView.translatesAutoresizingMaskIntoConstraints = false
        headImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        subheadImageView.translatesAutoresizingMaskIntoConstraints = false
        contentImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bylineImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            bylineImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            bylineImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            bylineImageView.heightAnchor.constraint(equalToConstant: 37),

            headImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            headImageView.topAnchor.constraint(equalTo: bylineImageView.bottomAnchor, constant: 18),
            headImageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.layoutMarginsGuide.trailingAnchor),
            headImageView.heightAnchor.constraint(equalToConstant: 162),

            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            thumbnailImageView.topAnchor.constraint(equalTo: headImageView.bottomAnchor, constant: 22),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            thumbnailImageView.heightAnchor.constraint(equalTo: thumbnailImageView.widthAnchor, multiplier: 9 / 16),

            subheadImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            subheadImageView.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 12),
            subheadImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            subheadImageView.heightAnchor.constraint(equalToConstant: 79),

            contentImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            contentImageView.topAnchor.constraint(equalTo: subheadImageView.bottomAnchor, constant: 55),
            contentImageView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            contentImageView.heightAnchor.constraint(equalToConstant: 692),
            contentImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
                .with(priority: .defaultHigh)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
