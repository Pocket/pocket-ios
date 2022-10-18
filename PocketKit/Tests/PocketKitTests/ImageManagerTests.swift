import XCTest
@testable import Kingfisher
@testable import PocketKit
@testable import Sync

class ImageManagerTests: XCTestCase {
    var imagesController: MockImagesController!
    var imageCache: MockImageCache!
    var imageRetriever: MockImageRetriever!
    var source: MockSource!
    var space: Space!

    override func setUp() {
        continueAfterFailure = false

        imagesController = MockImagesController()
        imageCache = MockImageCache()
        imageRetriever = MockImageRetriever(imageCache: imageCache)
        source = MockSource()
        space = Space.testSpace()

        imagesController.stubPerformFetch { }
        imageCache.stubRemoveImage { _, _, _, _, _, _ in }
        imageRetriever.stubRetrieveImage { _, _, _, _, _ in return nil }
        source.stubDownloadImages { _ in }
    }

    override func tearDownWithError() throws {
        try space.clear()
    }

    private func subject(
        imagesController: ImagesController? = nil,
        imageRetriever: ImageRetriever? = nil,
        source: Sync.Source? = nil
    ) -> ImageManager {
        ImageManager(
            imagesController: imagesController ?? self.imagesController,
            imageRetriever: imageRetriever ?? self.imageRetriever,
            source: source ?? self.source
        )
    }

    func test_whenImagesInsertedOrUpdated_downloadsEachImage() {
        imageRetriever.stubRetrieveImage { _, _, _, _, completion in
            let result = RetrieveImageResult(
                image: UIImage(),
                cacheType: .memory,
                source: .network(URL(string: "https://getpocket.com/example-image.png")!),
                originalSource: .network(URL(string: "https://getpocket.com/example-image.png")!),
                data: {
                    return nil
                }
            )
            completion?(.success(result))
            return nil
        }

        let prefetcher = subject()
        prefetcher.start()

        let images: [Image] = [
            space.buildImage(source: URL(string: "https://example.com/image-1.png")),
            space.buildImage(source: URL(string: "https://example.com/image-2.png")),
            space.buildImage(source: URL(string: "https://example.com/image-3.png")),
            space.buildImage(source: URL(string: "https://example.com/image-4.png")),
        ]
        imagesController.images = Array(images[0...1])

        imagesController.delegate?.controllerDidChangeContent(imagesController)

        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 0)?.resource as? URL, imageCacheURL(for: images[0].source))
        XCTAssertEqual(source.downloadImagesCall(at: 0)?.images.first, images[0])
        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 1)?.resource as? URL, imageCacheURL(for: images[1].source))
        XCTAssertEqual(source.downloadImagesCall(at: 0)?.images, imagesController.images)

        imagesController.delegate?.controller(
            imagesController,
            didChange: images[2],
            at: nil,
            for: .insert,
            newIndexPath: nil
        )

        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 2)?.resource as? URL, imageCacheURL(for: images[2].source))
        XCTAssertEqual(source.downloadImagesCall(at: 1)?.images, [images[2]])

        imagesController.delegate?.controller(
            imagesController,
            didChange: images[3],
            at: nil,
            for: .update,
            newIndexPath: nil
        )

        XCTAssertEqual(imageRetriever.retrieveImageCall(at: 3)?.resource as? URL, imageCacheURL(for: images[3].source))
        XCTAssertEqual(source.downloadImagesCall(at: 2)?.images, [images[3]])
    }

    func test_whenImagesAreMoved_doesNothing() {
        let prefetcher = subject()
        prefetcher.start()

        let images: [Image] = [
            space.buildImage(source: URL(string: "https://example.com/image-1.png")),
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
        XCTAssertNil(source.downloadImagesCall(at: 0))
    }

    func test_whenImagesAreDeleted_removesImageFromCache() {
        let prefetcher = subject()
        prefetcher.start()

        let images: [Image] = [
            space.buildImage(source: URL(string: "https://example.com/image-1.png")),
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
