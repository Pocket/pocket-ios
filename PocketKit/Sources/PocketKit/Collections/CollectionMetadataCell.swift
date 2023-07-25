// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher
import Textile

class CollectionMetadataCell: UICollectionViewCell {
    enum Constants {
        static let stackSpacing: CGFloat = 14
        static let layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
    }

    struct Model {
        let byline: NSAttributedString?
        let itemCount: NSAttributedString?
        let title: NSAttributedString?
        let intro: NSAttributedString?
    }

    private let bylineTextView = ArticleComponentTextView()
    private let itemCountView = ArticleComponentTextView()
    private let titleTextView = ArticleComponentTextView()
    private let introTextView = ArticleComponentTextView()

    private var metaStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private var textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(textStackView)
        textStackView.addArrangedSubview(metaStackView)
        textStackView.addArrangedSubview(titleTextView)
        textStackView.addArrangedSubview(introTextView)
        metaStackView.addArrangedSubview(bylineTextView)
        metaStackView.addArrangedSubview(itemCountView)

        contentView.layoutMargins = Constants.layoutMargins
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textStackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textStackView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textStackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(model: Model) {
        bylineTextView.attributedText = model.byline
        itemCountView.attributedText = model.itemCount
        titleTextView.attributedText = model.title
        introTextView.attributedText = model.intro

        bylineTextView.isHidden = model.byline == nil
        itemCountView.isHidden = model.itemCount == nil
        titleTextView.isHidden = model.title == nil
        introTextView.isHidden = model.intro == nil

        if model.byline == nil && model.itemCount == nil {
            textStackView.spacing = 0
        } else {
            textStackView.spacing = Constants.stackSpacing
        }
    }
}
