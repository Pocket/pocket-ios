// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol HomeCarouselCellConfiguration {
    var thumbnailURL: URL? { get }
    var saveButtonMode: ItemCellSaveButton.Mode? { get }
    var favoriteAction: ItemAction? { get }
    var overflowActions: [ItemAction]? { get }
    var saveAction: ItemAction? { get }
    var attributedCollection: NSAttributedString? { get }
    var attributedTitle: NSAttributedString { get }
    var attributedDomain: NSAttributedString { get }
    var attributedTimeToRead: NSAttributedString { get }
    var sharedWithYouUrlString: String? { get }
}
