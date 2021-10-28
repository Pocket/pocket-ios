import Sync
import UIKit
import Kingfisher


class ArticleComponentPresenter {
    let component: ArticleComponent
    var isEmpty: Bool = false
    var knownImageSize: CGSize?

    init(component: ArticleComponent) {
        self.component = component
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
        default:
            return .zero
        }
    }

    func attributedContent(for component: MarkdownComponent) -> NSAttributedString? {
        return NSAttributedString.styled(markdown: component.content)
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
            case .failure(let error):
                switch error {
                case .imageSettingError(let reason):
                    switch reason {
                    case .notCurrentSourceTask(let newResult, _, _):
                        self?.knownImageSize = newResult?.image.size
                        onSuccess()
                    default:
                        print("something")
                    }
                default:
                    print("narp")
                }
            }
        }
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
        return knownImageSize
        ?? CGSize(width: availableWidth, height: availableWidth * 9/16)
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
