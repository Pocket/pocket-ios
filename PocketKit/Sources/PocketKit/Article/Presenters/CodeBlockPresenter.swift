// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit
import Textile

private extension Style {
    static let codeBlock: Self = .body.monospace
}

class CodeBlockPresenter: ArticleComponentPresenter {
    var componentIndex: Int

    var highlightIndexes: [Int]?

    private let component: CodeBlockComponent

    private let readerSettings: ReaderSettings

    private var cachedCodeBlock: NSAttributedString?
    private var codeBlock: NSAttributedString? {
        cachedCodeBlock ?? loadCodeBlock()
    }

    init(component: CodeBlockComponent, readerSettings: ReaderSettings, componentIndex: Int) {
        self.component = component
        self.readerSettings = readerSettings
        self.componentIndex = componentIndex
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        codeBlock.flatMap {
            var size = $0.sizeFitting()
            size.height += CodeBlockComponentCell.Constants.contentInset.top
            + CodeBlockComponentCell.Constants.contentInset.bottom

            return size
        } ?? .zero
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, onHighlight: ((Int, NSRange, String, String) -> Void)?) -> UICollectionViewCell {
        let cell: CodeBlockComponentCell = collectionView.dequeueCell(for: indexPath)
        cell.textView.attributedText = codeBlock
        cell.componentIndex = componentIndex
        cell.onHighlight = onHighlight
        return cell
    }

    func clearCache() {
        cachedCodeBlock = nil
    }

    func loadContent() {
        loadCodeBlock()
    }

    @discardableResult
    private func loadCodeBlock() -> NSAttributedString? {
        let highlightedString = NSAttributedString(
            string: component.text,
            style: .codeBlock.modified(by: readerSettings)
        ).highlighted()
        cachedCodeBlock = highlightedString.content
        highlightIndexes = highlightedString.highlightInexes

        return cachedCodeBlock
    }
}
