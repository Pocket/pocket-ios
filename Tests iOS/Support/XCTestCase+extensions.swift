// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest

extension XCTestCase {
    func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 3) {
        let doesNotExist = NSPredicate(format: "exists == 0")
        let elementToNotExist = expectation(for: doesNotExist, evaluatedWith: element)
        wait(for: [elementToNotExist], timeout: timeout)
    }

    func waitForDisappearance(of element: PocketUIElement) {
        waitForDisappearance(of: element.element)
    }

    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: 20)
    }

    func fulfillment(of expectations: [XCTestExpectation]) async {
        await fulfillment(of: expectations, timeout: 20)
    }

    /// Very basic swipe to element function. As our needs increase, we will want something like https://github.com/PGSSoft/AutoMate/blob/master/AutoMate/XCTest%20extensions/XCUIElement%2BSwipe.swift
    /// - Parameters:
    ///   - element: Element to scroll to
    ///   - scrollableView: Scroll view to scroll
    ///   - maxSwipes: Max number of swipes to try.
    ///   - direction: Direction to swipe
    func scrollTo(element: XCUIElement, in scrollableView: XCUIElement, maxSwipes: Int = 10, direction: SwipeDirection) {
        var count = 0
        while element.isHittable == false && count < maxSwipes {
            defer { count += 1 }
            switch direction {
            case .up:
                scrollableView.swipeUp(velocity: .slow)
            case .down:
                scrollableView.swipeDown(velocity: .slow)
            case .left:
                scrollableView.swipeLeft(velocity: .slow)
            case .right:
                scrollableView.swipeRight(velocity: .slow)
            }
        }
    }
}

// MARK: - SwipeDirection
/// Swipe direction.
///
/// - `up`: Swipe up.
/// - `down`: Swipe down.
/// - `left`: Swipe to the left.
/// - `right`: Swipe to the right.
public enum SwipeDirection {
    /// Swipe up.
    case up // swiftlint:disable:this identifier_name
    /// Swipe down.
    case down
    /// Swipe to the left.
    case left
    /// Swipe to the right.
    case right
}
