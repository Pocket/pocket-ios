// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

@testable import Sync
@testable import PocketKit

class ImageComponentPresenterTests: XCTestCase { }

// MARK: - ImageComponentCell Model
extension ImageComponentPresenterTests {
    func test_model_withCaption_shouldShow() {
        let component = ImageComponent(
            caption: "a caption",
            credit: "a credit",
            height: 1,
            width: 2,
            id: 3,
            source: URL(string: "http://example.com")!
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }

        XCTAssertEqual(presenter.shouldHideCaption, false)
    }

    func test_model_withNoCaption_shouldHide() {
        let component = ImageComponent(
            caption: " ",
            credit: " ",
            height: 1,
            width: 2,
            id: 3,
            source: URL(string: "http://example.com")!
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }

        XCTAssertEqual(presenter.shouldHideCaption, true)
    }

    func test_model_imageViewBackgroundColor_withImageSizeAndCaption_returnsClearBackground() {
        let component = ImageComponent(
            caption: "a caption",
            credit: "a credit",
            height: 1,
            width: 2,
            id: 3,
            source: URL(string: "http://example.com")!
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }
        let imageSize = CGSize(width: 0, height: 0)

        XCTAssertEqual(presenter.imageViewBackgroundColor(imageSize: imageSize), UIColor(.clear))
    }

    func test_model_imageViewBackgroundColor_withImageSizeAndNoCaption_returnsClearBackground() {
        let component = ImageComponent(
            caption: " ",
            credit: " ",
            height: 1,
            width: 2,
            id: 3,
            source: URL(string: "http://example.com")!
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }
        let imageSize = CGSize(width: 0, height: 0)

        XCTAssertEqual(presenter.imageViewBackgroundColor(imageSize: imageSize), UIColor(.clear))
    }

    func test_model_imageViewBackgroundColor_withSmallImageSizeAndCaption_returnsGreyBackground() {
        let component = ImageComponent(
            caption: "a caption",
            credit: "a credit",
            height: 1,
            width: 2,
            id: 3,
            source: URL(string: "http://example.com")!
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }
        let imageSize = CGSize(width: -1, height: 0)

        XCTAssertEqual(presenter.imageViewBackgroundColor(imageSize: imageSize), UIColor(.ui.grey7))
    }

    func test_model_imageViewBackgroundColor_withSmallImageSizeAndNoCaption_returnsClearBackground() {
        let component = ImageComponent(
            caption: " ",
            credit: " ",
            height: 1,
            width: 2,
            id: 3,
            source: URL(string: "http://example.com")!
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }
        let imageSize = CGSize(width: -1, height: 0)

        XCTAssertEqual(presenter.imageViewBackgroundColor(imageSize: imageSize), UIColor(.clear))
    }

    func test_model_imageViewBackgroundColor_withNoImageAndCaption_returnsClearBackground() {
        let component = ImageComponent(
            caption: "a caption",
            credit: "a credit",
            height: 1,
            width: 2,
            id: 3,
            source: nil
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }
        let imageSize = CGSize(width: -1, height: 0)

        XCTAssertEqual(presenter.imageViewBackgroundColor(imageSize: imageSize), UIColor(.clear))
    }

    func test_model_imageViewBackgroundColor_withNoImageAndNoCaption_returnsClearBackground() {
        let component = ImageComponent(
            caption: nil,
            credit: nil,
            height: 1,
            width: 2,
            id: 3,
            source: nil
        )
        let presenter = ImageComponentPresenter(component: component, readerSettings: ReaderSettings(tracker: MockTracker(), userDefaults: .standard), componentIndex: 0) { }
        let imageSize = CGSize(width: -1, height: 0)

        XCTAssertEqual(presenter.imageViewBackgroundColor(imageSize: imageSize), UIColor(.clear))
    }
}
