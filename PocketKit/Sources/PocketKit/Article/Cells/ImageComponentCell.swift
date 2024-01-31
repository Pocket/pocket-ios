// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Kingfisher

protocol ImageComponentCellModel {
    var caption: NSAttributedString? { get }
    var image: ImageComponentCell.ImageSpec? { get }
    var shouldHideCaption: Bool { get }
    func imageViewBackgroundColor(imageSize: CGSize) -> UIColor
}

class ImageComponentCell: UICollectionViewCell {
    var componentIndex: Int = 0

    var onHighlight: ((Int, NSRange, String, String) -> Void)?

    enum Constants {
        static let captionSpacing: CGFloat = 4
        static let layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }

    struct ImageSpec {
        let source: URL
        let size: CGSize
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
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

        captionTextView.onHighlight = { [weak self] range, quote, text in
            guard let self else {
                return
            }
            onHighlight?(componentIndex, range, quote, text)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}

extension ImageComponentCell {
    func configure(model: ImageComponentCellModel, imageLoaded: ((UIImage) -> Void)? = nil) {
        captionTextView.attributedText = model.caption
        captionTextView.isHidden = model.shouldHideCaption

        imageView.image = nil
        guard let imageSpec = model.image else {
            return
        }

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: imageSpec.source,
            options: [
                .callbackQueue(.dispatch(.global(qos: .userInteractive))),
                .backgroundDecode,
                .processor(
                    OnlyResizeDownProcessor(
                        referenceSize: imageSpec.size,
                        mode: .aspectFit
                    )
                    .append(another: RoundCornerImageProcessor(radius: .point(4), backgroundColor: UIColor(.clear)))
                )
            ]
        ) { [weak self] result in
            switch result {
            case .success(let result):
                self?.imageView.backgroundColor = model.imageViewBackgroundColor(imageSize: result.image.size)
                imageLoaded?(result.image)
            case .failure:
                break
            }
        }
    }
}

private class OnlyResizeDownProcessor: ImageProcessor {
    let identifier: String

    let resizingProcessor: ResizingImageProcessor

    init(resizingProcessor: ResizingImageProcessor) {
        self.resizingProcessor = resizingProcessor
        self.identifier = "com.mozilla.getpocket.\(Self.self)(\(resizingProcessor.identifier))"
    }

    convenience init(referenceSize: CGSize, mode: ContentMode) {
        self.init(
            resizingProcessor: ResizingImageProcessor(
                referenceSize: referenceSize,
                mode: mode
            )
        )
    }

    func process(item: ImageProcessItem, options: KingfisherParsedOptionsInfo) -> KFCrossPlatformImage? {
        switch item {
        case .image(let image):
            guard image.size.width > resizingProcessor.referenceSize.width else {
                return image
            }

            return resizingProcessor.process(item: item, options: options)
        case .data:
            return (DefaultImageProcessor.default |> self).process(item: item, options: options)
        }
    }
}
