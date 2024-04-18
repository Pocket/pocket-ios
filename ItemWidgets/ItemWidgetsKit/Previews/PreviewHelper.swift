// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

extension ItemsListContentType {
    static var preview: ItemsListContentType {
        let standardRow = ItemRowContent(content: .placeHolder, image: Image(asset: .chest))
        let items = [ItemRowContent](repeating: standardRow, count: 4)
        return .items(items)
    }
}
