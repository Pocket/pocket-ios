import Sync
import UIKit
import Kingfisher
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

class ImageComponentPresenter: ArticleComponentPresenter {
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

    init(component: ImageComponent, readerSettings: ReaderSettings, onUpdate: @escaping () -> Void) {
        self.component = component
        self.readerSettings = readerSettings
        self.onUpdate = onUpdate
    }

    var caption: NSAttributedString? {
        let base = NSMutableAttributedString()

        if let attributedCaption = attributedCaption {
            base.append(attributedCaption)
        }

        if let attributedCredit = attributedCredit {
            if !base.string.isEmpty {
                base.append(NSAttributedString(string: " ", style: .imageCredit.adjustingSize(by: readerSettings.fontSizeAdjustment)))
            }

            base.append(attributedCredit)
        }

        return base
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
    
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: ImageComponentCell = collectionView.dequeueCell(for: indexPath)

        cell.configure(
            model: .init(
                caption: caption,
                image: imageCacheURL(for: component.source).flatMap {
                    ImageComponentCell.ImageSpec(
                        source: $0,
                        size: CGSize(
                            width: lastAvailableWidth,
                            height: .greatestFiniteMagnitude
                        )
                    )
                }
            )
        ) { [weak self] image in
            self?.lastImageSize = image.size
            self?.onUpdate()
        }

        return cell
    }

    func clearCache() {
        cachedAttributedCredit = nil
        cachedAttributedCaption = nil
        lastImageSize = nil
    }

    private func loadAttributedCredit() -> NSAttributedString? {
        cachedAttributedCredit = component.credit.flatMap {
            NSAttributedString(
                string: $0,
                style: .imageCredit.adjustingSize(by: readerSettings.fontSizeAdjustment)
            )
        }

        return cachedAttributedCredit
    }

    private func loadAttributedCaption() -> NSAttributedString? {
        cachedAttributedCaption = component.caption.flatMap {
            NSAttributedString(
                string: $0,
                style: .imageCaption.adjustingSize(by: readerSettings.fontSizeAdjustment)
            )
        }

        return cachedAttributedCaption
    }
}
