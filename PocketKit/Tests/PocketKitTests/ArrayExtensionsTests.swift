// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
@testable import PocketKit

class ArrayExtensionsTests: XCTestCase {
    func test_maxHeightForRow_withSizeThree_returnsValidHeights() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.maxHeightForRow(of: 3)
        XCTAssertEqual(rowHeights, [5.0, 10.2, 11.0])
    }

    func test_maxHeightForRow_withSizeTwo_returnsValidHeights() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.maxHeightForRow(of: 2)
        XCTAssertEqual(rowHeights, [5.0, 5.0, 10.2, 11.0])
    }

    func test_maxHeightForRow_withSizeZero_returnsEmptyResults() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.maxHeightForRow(of: 0)
        XCTAssertEqual(rowHeights, [])
    }

    func test_maxHeightForRow_withSizeNegative_returnsEmptyResults() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.maxHeightForRow(of: -1)
        XCTAssertEqual(rowHeights, [])
    }
}
