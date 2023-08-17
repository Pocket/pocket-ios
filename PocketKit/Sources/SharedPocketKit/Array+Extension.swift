// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}

extension Array where Element == CGFloat {
    /// Retrieves a list of heights for each row
    /// - Parameter size: number of items in a row
    /// - Returns: list of heights for each row
    public func getMaxHeightForRow(of size: Int) -> [CGFloat] {
        guard size > 0 else { return [] }
        var maxHeights: [CGFloat] = []

        for index in stride(from: 0, to: count, by: size) {
            let lastChunkIndex = Swift.min(index + size, count)
            let row = self[index..<lastChunkIndex]

            if let maxValue = row.sorted().last {
                maxHeights.append(maxValue)
            }
        }

        return maxHeights
    }
}
