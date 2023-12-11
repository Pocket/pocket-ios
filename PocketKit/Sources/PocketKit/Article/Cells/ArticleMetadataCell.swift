// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class ArticleMetadataCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    enum Constants {
        static let stackSpacing: CGFloat = 14
        static let layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 14, right: 0)
    }

    struct Model {
        let byline: NSAttributedString?
        let publishedDate: NSAttributedString?
        let title: NSAttributedString?
    }

    private let bylineTextView = ArticleComponentTextView()
    private let publishedDateTextView = ArticleComponentTextView()
    private let titleTextView = ArticleComponentTextView()

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

    weak var delegate: ArticleComponentTextCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        bylineTextView.actionDelegate = self
        publishedDateTextView.actionDelegate = self
        titleTextView.actionDelegate = self

        contentView.addSubview(textStack)
        textStack.addArrangedSubview(metaStack)
        textStack.addArrangedSubview(titleTextView)
        metaStack.addArrangedSubview(bylineTextView)
        metaStack.addArrangedSubview(publishedDateTextView)

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
        publishedDateTextView.attributedText = model.publishedDate
        titleTextView.attributedText = model.title

        bylineTextView.isHidden = model.byline == nil
        publishedDateTextView.isHidden = model.publishedDate == nil
        titleTextView.isHidden = model.title == nil

        if model.byline == nil && model.publishedDate == nil {
            textStack.spacing = 0
        } else {
            textStack.spacing = Constants.stackSpacing
        }
    }
}
