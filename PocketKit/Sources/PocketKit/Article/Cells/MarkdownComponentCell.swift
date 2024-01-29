// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class MarkdownComponentCell: UICollectionViewCell, ArticleComponentTextCell, ArticleComponentTextViewDelegate {
    var componentIndex: Int = 0

    var onHighlight: ((Int, NSRange) -> Void)?

    enum Constants {
        enum Heading {
            static let layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        }

        enum Body {
            static let layoutMargins = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        }

        enum List {
            static let layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        }
    }

    lazy var textView: ArticleComponentTextView = {
        let textView = ArticleComponentTextView()
        textView.actionDelegate = self
        return textView
    }()

    weak var delegate: ArticleComponentTextCellDelegate?

    var selectedText: String {
        (textView.text as NSString).substring(with: textView.selectedRange)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(textView)

        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            textView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
            // set lower priority to avoid conflict if content turns out to be blank
                .with(priority: .defaultLow)
        ])

        textView.onHighlight = { [weak self] range in
            guard let self else {
                return
            }
            onHighlight?(componentIndex, range)
        }
    }

    var attributedContent: NSAttributedString? {
        get {
            textView.attributedText
        }
        set {
            textView.attributedText = newValue
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}
