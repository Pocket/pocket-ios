import Sync
import UIKit
import Kingfisher
import Textile


private extension Style {
    static let imageCredit: Self = .body.sansSerif
        .with(size: .p4)
        .with(color: .ui.grey3)
        .with(slant: .italic)

    static let imageCaption: Self = .body.sansSerif.with(size: .p3)
}

class ArticleComponentPresenter {
    private let readerSettings: ReaderSettings
    
    let component: ArticleComponent
    var isEmpty: Bool = false
    var knownImageSize: CGSize?

    init(component: ArticleComponent, readerSettings: ReaderSettings) {
        self.component = component
        self.readerSettings = readerSettings
        isEmpty = component.isEmpty || size(fittingWidth: .greatestFiniteMagnitude).height <= 0
    }

    func size(fittingWidth availableWidth: CGFloat) -> CGSize {
        guard !isEmpty else {
            return .zero
        }

        switch component {
        case .heading(let heading):
            return componentSize(of: heading, availableWidth: availableWidth)
        case .text(let text):
            return componentSize(of: text, availableWidth: availableWidth)
        case .image(let image):
            return componentSize(of: image, availableWidth: availableWidth)
        case .divider:
            return CGSize(width: availableWidth, height: 16)
        default:
            return .zero
        }
    }

    func attributedContent(for component: MarkdownComponent) -> NSAttributedString? {
        NSAttributedString.styled(
            markdown: component.content,
            styler: NSMutableAttributedString.defaultStyler(with: readerSettings)
        )
    }

    func loadImage(
        into imageView: UIImageView,
        availableWidth: CGFloat,
        onSuccess: @escaping () -> Void
    ) {
        guard case .image(let image) = component,
              let source = image.source else {
            return
        }

        let size = CGSize(
            width: availableWidth,
            height: .greatestFiniteMagnitude
        )

        let cachedSource = imageCacheURL(for: source)
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: cachedSource,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(
                    OnlyResizeDownProcessor(
                        resizingProcessor: ResizingImageProcessor(
                            referenceSize: size,
                            mode: .aspectFit
                        )
                     )
                )
            ]
        ) { [weak self] result in
            switch result {
            case .success(let retrieveResult):
                self?.knownImageSize = retrieveResult.image.size
                onSuccess()
            case .failure:
                break
            }
        }
    }

    func attributedCaption(for string: String?) -> NSAttributedString? {
        string.flatMap { NSAttributedString(string: $0, style: .imageCaption.modified(by: readerSettings)) }
    }

    func attributedCredit(for string: String?) -> NSAttributedString? {
        string.flatMap { NSAttributedString(string: $0, style: .imageCredit.modified(by: readerSettings)) }
    }

    private func componentSize(of component: MarkdownComponent, availableWidth: CGFloat) -> CGSize {
        guard !component.isEmpty, let text = attributedContent(for: component) else {
            return .zero
        }

        let height = Self.height(
            of: text,
            width: availableWidth
        )

        return CGSize(
            width: availableWidth,
            height: height
        )
    }

    static func height(of attributedString: NSAttributedString, width: CGFloat) -> CGFloat {
        guard !attributedString.string.isEmpty else {
            return 0
        }

        let rect = attributedString.boundingRect(
            with: CGSize(width: width, height: .infinity),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        )

        return rect.height.rounded(.up)
    }

    private func componentSize(of component: ImageComponent, availableWidth: CGFloat) -> CGSize {
        var cellHeight = knownImageSize?.height ?? availableWidth * 9/16

        if let caption = attributedCaption(for: component.caption) {
            cellHeight += Self.height(of: caption, width: availableWidth) + 8
        }

        if let credit = attributedCredit(for: component.credit) {
            cellHeight += Self.height(of: credit, width: availableWidth) + 8
        }

        return CGSize(width: availableWidth, height: cellHeight)
    }
}

class OnlyResizeDownProcessor: ImageProcessor {
    let identifier = "com.getpocket.image-processor.only-resize-down"

    let resizingProcessor: ResizingImageProcessor

    init(resizingProcessor: ResizingImageProcessor) {
        self.resizingProcessor = resizingProcessor
    }

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            guard image.size.height > resizingProcessor.referenceSize.height
                    || image.size.width > resizingProcessor.referenceSize.width else {
                        return image
                    }

            return resizingProcessor.process(item: item, options: options)
        case .data:
            return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}
