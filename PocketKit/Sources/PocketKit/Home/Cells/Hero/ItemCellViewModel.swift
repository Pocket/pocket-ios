// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// View models of cells used in Unified Home can conform to this protocol
/// to use a set of standard elements
protocol ItemCellViewModel {
    var attributedCollection: NSAttributedString? { get }
    var attributedTitle: NSAttributedString { get }
    var attributedExcerpt: NSAttributedString? { get }
    var attributedDomain: NSAttributedString { get }
    var attributedTimeToRead: NSAttributedString { get }
    var imageURL: URL? { get }
    var saveButtonMode: ItemCellSaveButton.Mode { get }
    var overflowActions: [ItemAction]? { get }
    var primaryAction: ItemAction? { get }
    var sharedWithYouUrlString: String? { get }
}
