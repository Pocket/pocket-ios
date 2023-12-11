// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import UIKit

class MarkdownComponentPresenter: ArticleComponentPresenter {
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
        cachedContent ?? loadContent()
    }

    init(
        component: MarkdownComponent,
        readerSettings: ReaderSettings,
        componentType: ComponentType
    ) {
        self.component = component
        self.readerSettings = readerSettings
        self.componentType = componentType
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

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: MarkdownComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.contentView.layoutMargins = componentType.margins
        cell.attributedContent = content

        return cell
    }

    func clearCache() {
        cachedContent = nil
    }

    private func loadContent() -> NSAttributedString? {
        cachedContent = NSAttributedString.styled(
            markdown: component.content,
            styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
        )

        return cachedContent
    }
}
