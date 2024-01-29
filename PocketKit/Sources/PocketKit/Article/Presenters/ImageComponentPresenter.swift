// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit
import Kingfisher
import SharedPocketKit
import Textile

private extension Style {
    static let imageCaption: Self = .body.serif
        .with(size: .p4)
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.12))
        }
        .with(slant: .italic)
        .with(color: .ui.grey3)

    static let imageCredit: Self = .body.sansSerif
        .with(size: .p5)
        .with { (paragraph: ParagraphStyle) -> ParagraphStyle in
            paragraph.with(lineHeight: .multiplier(1.12))
        }
        .with(weight: .medium)
        .with(color: .ui.grey3)
}

class ImageComponentPresenter: ArticleComponentPresenter, ImageComponentCellModel {
    var componentIndex: Int

    var highlightIndexes: [Int]?

    private let component: ImageComponent

    private let readerSettings: ReaderSettings

    private let onUpdate: () -> Void

    private var lastImageSize: CGSize?

    private var lastAvailableWidth: CGFloat = 0

    private var cachedAttributedCaption: NSAttributedString?
    private var attributedCaption: NSAttributedString? {
        cachedAttributedCaption ?? loadAttributedCaption()
    }

    private var cachedAttributedCredit: NSAttributedString?
    private var attributedCredit: NSAttributedString? {
        cachedAttributedCredit ?? loadAttributedCredit()
    }

    init(component: ImageComponent, readerSettings: ReaderSettings, componentIndex: Int, onUpdate: @escaping () -> Void) {
        self.component = component
        self.readerSettings = readerSettings
        self.componentIndex = componentIndex
        self.onUpdate = onUpdate
    }

    var caption: NSAttributedString? {
        let base = NSMutableAttributedString()

        if let attributedCaption = attributedCaption {
            base.append(attributedCaption)
        }

        if let attributedCredit = attributedCredit {
            if !base.string.isEmpty {
                base.append(NSAttributedString(string: " ", style: .imageCredit.modified(by: readerSettings)))
            }

            base.append(attributedCredit)
        }
        let highlightedBase = base.highlighted()
        highlightIndexes = highlightedBase.highlightInexes
        return highlightedBase.content
    }

    var image: ImageComponentCell.ImageSpec? {
        return CDNURLBuilder().imageCacheURL(for: component.source).flatMap {
            ImageComponentCell.ImageSpec(
                source: $0,
                size: CGSize(
                    width: lastAvailableWidth,
                    height: .greatestFiniteMagnitude
                )
            )
        }
    }

    var shouldHideCaption: Bool {
        return caption == nil || caption?.string.trimmingCharacters(in: .whitespaces).isEmpty == true
    }

    func imageViewBackgroundColor(imageSize: CGSize) -> UIColor {
        guard let idealWidth = image?.size.width else { return UIColor(.clear) }

        if imageSize.width >= idealWidth || shouldHideCaption {
            return UIColor(.clear)
        } else {
            return UIColor(.ui.grey7)
        }
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        lastAvailableWidth = availableWidth

        var height = lastImageSize?.height ?? availableWidth * 9 / 16

        if let caption = caption, !caption.string.isEmpty {
            height += ImageComponentCell.Constants.captionSpacing
            height += caption.sizeFitting(availableWidth: availableWidth).height
        }

        height += ImageComponentCell.Constants.layoutMargins.top
        height += ImageComponentCell.Constants.layoutMargins.bottom

        return CGSize(width: availableWidth, height: height)
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView, onHighlight: ((Int, NSRange) -> Void)?) -> UICollectionViewCell {
        let cell: ImageComponentCell = collectionView.dequeueCell(for: indexPath)

        cell.configure(model: self) { [weak self] image in
            self?.lastImageSize = image.size
            self?.onUpdate()
        }
        cell.componentIndex = componentIndex
        cell.onHighlight = onHighlight

        return cell
    }

    func clearCache() {
        cachedAttributedCredit = nil
        cachedAttributedCaption = nil
        lastImageSize = nil
    }

    func loadContent() {
        // calling caption will load the highlighted content
        _ = caption
    }

    @discardableResult
    private func loadAttributedCredit() -> NSAttributedString? {
        cachedAttributedCredit = component.credit.flatMap {
            NSAttributedString(
                string: $0,
                style: .imageCredit.modified(by: readerSettings)
            )
        }

        return cachedAttributedCredit
    }

    @discardableResult
    private func loadAttributedCaption() -> NSAttributedString? {
        cachedAttributedCaption = component.caption.flatMap {
            NSAttributedString(
                string: $0,
                style: .imageCaption.modified(by: readerSettings)
            )
        }

        return cachedAttributedCaption
    }
}
