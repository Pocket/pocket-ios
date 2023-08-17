// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import SharedPocketKit

class ArrayExtensionsTests: XCTestCase {
    func test_getMaxHeightForRow_withSizeThree_returnsValidHeights() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.getMaxHeightForRow(of: 3)
        XCTAssertEqual(rowHeights, [5.0, 10.2, 11.0])
    }

    func test_getMaxHeightForRow_withSizeTwo_returnsValidHeights() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.getMaxHeightForRow(of: 2)
        XCTAssertEqual(rowHeights, [5.0, 5.0, 10.2, 11.0])
    }

    func test_getMaxHeightForRow_withSizeZero_returnsEmptyResults() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.getMaxHeightForRow(of: 0)
        XCTAssertEqual(rowHeights, [])
    }

    func test_getMaxHeightForRow_withSizeNegative_returnsEmptyResults() {
        let array: [CGFloat] = [3.0, 5.0, 5.0, 4.0, 10.2, 8.0, 11.0]
        let rowHeights = array.getMaxHeightForRow(of: -1)
        XCTAssertEqual(rowHeights, [])
    }
}
