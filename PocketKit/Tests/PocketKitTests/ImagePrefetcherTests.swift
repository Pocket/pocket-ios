import XCTest
import Sync
@testable import PocketKit


class ImagePrefetcherTests: XCTestCase {
    var imagesController: MockImagesController!
    var imageCache: MockImageCache!
    var imageRetriever: MockImageRetriever!

    override func setUp() {
        continueAfterFailure = false

        imagesController = MockImagesController()
        imageCache = MockImageCache()
        imageRetriever = MockImageRetriever(imageCache: imageCache)

        imagesController.stubPerformFetch { }
        imageCache.stubRemoveImage { _, _, _, _, _, _ in }
        imageRetriever.stubRetrieveImage { _, _, _, _, _ in return nil }
    }

    private func subject(
        imagesController: ImagesController? = nil,
        imageRetriever: ImageRetriever? = nil
    ) -> ImageManager {
        ImageManager(
            imagesController: imagesController ?? self.imagesController,
            imageRetriever: imageRetriever ?? self.imageRetriever
        )
    }

    func test_whenImagesInsertedOrUpdated_downloadsEachImage() {
        let prefetcher = subject()

        let images: [Image] = [
            .build(source: URL(string: "https://example.com/image-1.png")),
            .build(source: URL(string: "https://example.com/image-2.png")),
            .build(source: URL(string: "https://example.com/image-3.png")),
            .build(source: URL(string: "https://example.com/image-4.png")),
        ]
        imagesController.images = Array(images[0...1])

        imagesController.delegate?.controllerDidChangeContent(imagesController)

        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 0)?.resource as? URL, imageCacheURL(for: images[0].source))
        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 1)?.resource as? URL, imageCacheURL(for: images[1].source))

        imagesController.delegate?.controller(
            imagesController,
            didChange: images[2],
            at: nil,
            for: .insert,
            newIndexPath: nil
        )

        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 2)?.resource as? URL, imageCacheURL(for: images[2].source))

        imagesController.delegate?.controller(
            imagesController,
            didChange: images[3],
            at: nil,
            for: .update,
            newIndexPath: nil
        )

        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 3)?.resource as? URL, imageCacheURL(for: images[3].source))
    }

    func test_whenImagesAreMoved_doesNothing() {
        let prefetcher = subject()

        let images: [Image] = [
            .build(source: URL(string: "https://example.com/image-1.png")),
        ]
        imagesController.images = images

        imagesController.delegate?.controller(
            imagesController,
            didChange: images[0],
            at: nil,
            for: .move,
            newIndexPath: nil
        )

        XCTAssertNil(imageRetriever.retrieveImageCall(at: 0))
    }

    func test_whenImagesAreDeleted_removesImageFromCache() {
        let prefetcher = subject()

        let images: [Image] = [
            .build(source: URL(string: "https://example.com/image-1.png")),
        ]
        imagesController.images = images

        imagesController.delegate?.controller(
            imagesController,
            didChange: images[0],
            at: nil,
            for: .delete,
            newIndexPath: nil
        )

        XCTAssertEqual(
            imageCache.removeImageCall(at: 0)?.key,
            imageCacheURL(for: images[0].source!)!.cacheKey
        )
    }
}
