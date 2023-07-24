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

    private var metaStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private var textStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(textStack)
        textStack.addArrangedSubview(metaStack)
        textStack.addArrangedSubview(titleTextView)
        textStack.addArrangedSubview(introTextView)
        metaStack.addArrangedSubview(bylineTextView)
        metaStack.addArrangedSubview(itemCountView)

        contentView.layoutMargins = Constants.layoutMargins
        textStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textStack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textStack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textStack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
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
            textStack.spacing = 0
        } else {
            textStack.spacing = Constants.stackSpacing
        }
    }
}
