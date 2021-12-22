import UIKit
import Kingfisher


class ImageComponentCell: UICollectionViewCell {
    enum Constants {
        static let captionSpacing: CGFloat = 4
        static let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }

    struct ImageSpec {
        let source: URL
        let size: CGSize
    }

    struct Model {
        let caption: NSAttributedString?
        let image: ImageSpec?
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        return imageView
    }()

    private let captionTextView = ArticleComponentTextView()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = Constants.captionSpacing

        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(stack)
        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(captionTextView)

        contentView.layoutMargins = Constants.layoutMargins
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}

extension ImageComponentCell {
    func configure(model: Model, imageLoaded: ((UIImage) -> Void)? = nil) {
        captionTextView.attributedText = model.caption
        captionTextView.isHidden = model.caption == nil

        imageView.image = nil
        guard let imageSpec = model.image else {
            return
        }

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageSpec.source,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(
                    OnlyResizeDownProcessor(size: imageSpec.size, mode: .aspectFit)
                )
            ]
        ) { result in
            switch result {
            case .success(let result):
                imageLoaded?(result.image)
            case .failure:
                break
            }
        }
    }
}

private class OnlyResizeDownProcessor: ImageProcessor {
    let identifier = "com.getpocket.image-processor.only-resize-down"

    let resizingProcessor: ResizingImageProcessor

    init(resizingProcessor: ResizingImageProcessor) {
        self.resizingProcessor = resizingProcessor
    }

    convenience init(size: CGSize, mode: ContentMode) {
        self.init(
            resizingProcessor: ResizingImageProcessor(
                referenceSize: size,
                mode: mode
            )
        )
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
