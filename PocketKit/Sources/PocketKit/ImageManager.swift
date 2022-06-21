import Foundation
import Kingfisher
import Sync
import CoreData

protocol ImageCacheProtocol {
    func removeImage(forKey key: String,
                          processorIdentifier identifier: String,
                          fromMemory: Bool,
                          fromDisk: Bool,
                          callbackQueue: CallbackQueue,
                          completionHandler: (() -> Void)?
    )
}

extension ImageCache: ImageCacheProtocol { }

protocol ImageRetriever {
    var imageCache: ImageCacheProtocol { get }

    @discardableResult
    func retrieveImage(
        with resource: Resource,
        options: KingfisherOptionsInfo?,
        progressBlock: DownloadProgressBlock?,
        downloadTaskUpdated: DownloadTaskUpdatedBlock?,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?
    ) -> DownloadTask?
}

extension KingfisherManager: ImageRetriever {
    var imageCache: ImageCacheProtocol {
        cache
    }
}

class ImageManager {
    private let imagesController: ImagesController
    private let imageRetriever: ImageRetriever
    private let source: Sync.Source

    init(
        imagesController: ImagesController,
        imageRetriever: ImageRetriever,
        source: Sync.Source
    ) {
        self.imagesController = imagesController
        self.imageRetriever = imageRetriever
        self.source = source
    }

    func start() {
        imagesController.delegate = self
        try? imagesController.performFetch()

        imagesController.images?.forEach { download(image: $0) }
    }
}

private extension ImageManager {
    func download(image: Image, _ completion: ((Bool) -> Void)? = nil) {
        guard let source = image.source, let cachedSource = imageCacheURL(for: source) else {
            return
        }

        imageRetriever.retrieveImage(
            with: cachedSource,
            options: nil,
            progressBlock: nil,
            downloadTaskUpdated: nil) { result in
                switch result {
                case .success:
                    completion?(true)
                default:
                    completion?(false)
                }
            }
    }

    func delete(image: Image) {
        guard let source = image.source, let cachedSource = imageCacheURL(for: source) else {
            return
        }

        imageRetriever.imageCache.removeImage(
            forKey: cachedSource.cacheKey,
            processorIdentifier: "",
            fromMemory: true,
            fromDisk: true,
            callbackQueue: .untouch,
            completionHandler: nil
        )
    }
}

extension ImageManager: ImagesControllerDelegate {
    func controller(
        _ controller: ImagesController,
        didChange image: Image,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert, .update:
            download(image: image) { [weak self] success in
                if success {
                    self?.source.download(images: [image])
                }
            }
        case .delete:
            delete(image: image)
        case .move:
            return
        @unknown default:
            return
        }
    }

    func controllerDidChangeContent(_ controller: ImagesController) {
        guard let images = controller.images, !images.isEmpty else {
            return
        }

        images.forEach { download(image: $0) }
        source.download(images: images)
    }
}
