// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import UIKit

class MarkdownComponentPresenter: ArticleComponentPresenter {
    var componentIndex: Int

    var highlightIndexes: [Int]?

    enum ComponentType {
        case heading
        case body

        fileprivate var margins: UIEdgeInsets {
            switch self {
            case .heading:
                return MarkdownComponentCell.Constants.Heading.layoutMargins
            case .body:
                return MarkdownComponentCell.Constants.Body.layoutMargins
            }
        }
    }

    private let component: MarkdownComponent

    private let readerSettings: ReaderSettings

    private let componentType: ComponentType

    private var cachedContent: NSAttributedString?
    private var content: NSAttributedString? {
        cachedContent ?? loadMarkdownContent()
    }

    init(
        component: MarkdownComponent,
        readerSettings: ReaderSettings,
        componentType: ComponentType,
        componentIndex: Int
    ) {
        self.component = component
        self.readerSettings = readerSettings
        self.componentType = componentType
        self.componentIndex = componentIndex
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        guard let content = content, !content.string.isEmpty else {
            return .zero
        }

        var size = content.sizeFitting(availableWidth: availableWidth)
        size.height += componentType.margins.top
        size.height += componentType.margins.bottom

        return size
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, onHighlight: ((Int, NSRange, String, String) -> Void)?) -> UICollectionViewCell {
        let cell: MarkdownComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.contentView.layoutMargins = componentType.margins
        cell.attributedContent = content
        cell.componentIndex = componentIndex
        cell.onHighlight = onHighlight
        return cell
    }

    func clearCache() {
        cachedContent = nil
    }

    func loadContent() {
        loadMarkdownContent()
    }

    @discardableResult
    private func loadMarkdownContent() -> NSAttributedString? {
        let highlightedString = NSAttributedString.styled(
            markdown: component.content,
            styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
        )?.highlighted()
        cachedContent = highlightedString?.content
        highlightIndexes = highlightedString?.highlightInexes

        return cachedContent
    }
}
