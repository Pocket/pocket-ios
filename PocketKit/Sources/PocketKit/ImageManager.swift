// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Kingfisher
import SharedPocketKit
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

    func isCached(forKey key: String, processorIdentifier identifier: String) -> Bool
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
    private let cdnURLBuilder: CDNURLBuilder

    init(
        imagesController: ImagesController,
        imageRetriever: ImageRetriever,
        source: Sync.Source,
        cdnURLBuilder: CDNURLBuilder
    ) {
        self.imagesController = imagesController
        self.imageRetriever = imageRetriever
        self.source = source
        self.cdnURLBuilder = cdnURLBuilder
    }

    func start() {
        imagesController.delegate = self
        try? imagesController.performFetch()
        // handle(images: imagesController.images)
    }
}

private extension ImageManager {
    func download(url: URL, _ completion: ((Bool) -> Void)? = nil) {
        // 1. Check if we have a valid image cache url
        // 2. Check if the image is already cached
        // If the image has a valid url and is already cached, skip; else, retrieve
        guard let cachedURL = cdnURLBuilder.imageCacheURL(for: url),
        imageRetriever.imageCache.isCached(
            forKey: cachedURL.cacheKey,
            processorIdentifier: DefaultImageProcessor.default.identifier
        ) == false else {
            return
        }

        imageRetriever.retrieveImage(
            with: cachedURL,
            options: nil,
            progressBlock: nil,
            downloadTaskUpdated: nil
        ) { result in
            switch result {
            case .success:
                completion?(true)
            default:
                completion?(false)
            }
        }
    }

    func delete(url: URL) {
        // 1. Check if we have a valid image cache url
        // 2. Check if the image is already cached
        // If the image has a valid url and is not already cached, skip; else, delete
        guard let cachedURL = cdnURLBuilder.imageCacheURL(for: url),
        imageRetriever.imageCache.isCached(
            forKey: cachedURL.cacheKey,
            processorIdentifier: DefaultImageProcessor.default.identifier
        ) == true else {
            return
        }

        imageRetriever.imageCache.removeImage(
            forKey: cachedURL.cacheKey,
            processorIdentifier: DefaultImageProcessor.default.identifier,
            fromMemory: true,
            fromDisk: true,
            callbackQueue: .untouch,
            completionHandler: nil
        )
    }

    func handle(images: [CDImage]?) {
        guard let images = images, !images.isEmpty else {
            return
        }

        // Images are removed via `removeFromImages` when Items are updated
        // This nullifies the item relationship from Image -> Item
        // Therefore, we want to retrieve orphaned Images so we can delete them
        let orphans = images.filter { $0.item == nil && $0.recommendation == nil && $0.syndicatedArticle == nil }

        let allURLs = Set(images.compactMap { $0.source })
        let orphanURLs = Set(orphans.compactMap { $0.source })

        // All URLs that are not orphans
        let toDownload = allURLs.subtracting(orphanURLs)
        // Skip deleting any URLs that are also orphans, as to not redownload
        let skipDelete = toDownload.intersection(orphanURLs)
        // Delete all orphan URLs that are not to be skipped
        let toDelete = orphanURLs.subtracting(skipDelete)

        toDelete.forEach { delete(url: $0) }
        toDownload.forEach { download(url: $0) }

        source.delete(images: orphans)
    }
}

extension ImageManager: ImagesControllerDelegate {
    func controllerDidChangeContent(_ controller: ImagesController) {
        // Called once all context changes are saved (inserts, deletes, etc)
        // so we can bulk handle the latest Images
        // handle(images: controller.images)
    }
}
