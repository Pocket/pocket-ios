// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import Kingfisher
@testable import PocketKit
@testable import Sync

// Commenting out for now
// class ImageManagerTests: XCTestCase {
//    var imagesController: MockImagesController!
//    var imageCache: MockImageCache!
//    var imageRetriever: MockImageRetriever!
//    var source: MockSource!
//    var space: Space!
//
//    override func setUp() {
//        continueAfterFailure = false
//
//        imagesController = MockImagesController()
//        imageCache = MockImageCache()
//        imageRetriever = MockImageRetriever(imageCache: imageCache)
//        source = MockSource()
//        space = Space.testSpace()
//
//        imagesController.stubPerformFetch { }
//        imageCache.stubRemoveImage { _, _, _, _, _, _ in }
//        imageRetriever.stubRetrieveImage { _, _, _, _, _ in return nil }
//        source.stubDeleteImages { _ in }
//    }
//
//    override func tearDownWithError() throws {
//        try space.clear()
//    }
//
//    private func subject(
//        imagesController: ImagesController? = nil,
//        imageRetriever: ImageRetriever? = nil,
//        source: Sync.Source? = nil
//    ) -> ImageManager {
//        ImageManager(
//            imagesController: imagesController ?? self.imagesController,
//            imageRetriever: imageRetriever ?? self.imageRetriever,
//            source: source ?? self.source
//        )
//    }
//
//    func test_onStart_withNoOrphans_andNoCachedImages_downloadsImages() {
//        imagesController.images = [
//            try! space.createImage(
//                source: URL(string: "https://getpocket.com"),
//                item: try! space.createItem()
//            )
//        ]
//
//        imageCache.stubIsCached { _, _ in
//            return false
//        }
//
//        let subject = subject()
//
//        subject.start()
//
//        let resource = imageRetriever.retrieveImageCall(at: 0)?.resource
//        let expectedURL = imageCacheURL(for: imagesController.images!.first!.source)
//
//        // Force unwrapping also tests for nil; two-in-one
//        XCTAssertEqual(resource!.downloadURL, expectedURL)
//    }
//
//    func test_onStart_withNoOrphans_andCachedImages_doesNothing() {
//        imagesController.images = [
//            try! space.createImage(
//                source: URL(string: "https://getpocket.com"),
//                item: try! space.createItem()
//            )
//        ]
//
//        imageCache.stubIsCached { _, _ in
//            return true
//        }
//
//        let subject = subject()
//
//        subject.start()
//
//        XCTAssertNil(imageRetriever.retrieveImageCall(at: 0))
//    }
//
//    func test_onStart_withOrphans_andNoCachedImages_deletesImagesFromSource() {
//        imagesController.images = [
//            try! space.createImage(
//                source: URL(string: "https://getpocket.com/"),
//                item: try! space.createItem()
//            ),
//            try! space.createImage(
//                source: URL(string: "https://getpocket.com/orphan")
//            )
//        ]
//
//        imageCache.stubIsCached { _, _ in
//            return false
//        }
//
//        let subject = subject()
//
//        subject.start()
//
//        XCTAssertEqual(
//            source.deleteImagesCall(at: 0)!.images[0],
//            imagesController.images![1]
//        )
//    }
//
//    func test_onStart_withOrphans_andCachedImages_removesOrphansFromCache() {
//        imagesController.images = [
//            try! space.createImage(
//                source: URL(string: "https://getpocket.com/orphan")
//            )
//        ]
//
//        imageCache.stubIsCached { _, _ in
//            return true
//        }
//
//        let subject = subject()
//
//        subject.start()
//
//        let expectedKey = imageCacheURL(for: imagesController.images![0].source!)!.absoluteString
//        XCTAssertEqual(
//            imageCache.removeImageCall(at: 0)!.key,
//            expectedKey
//        )
//    }
// }
