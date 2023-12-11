// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

///
/// Wraps an item that can be shared
/// This class exists because providing a simple array of basic types (e.g. URL, String) would just
/// concatenate the items together, which kills the URL preview that appears when sharing in messages.
/// Wrapping items in a `UIActivityItemSource` is a signal that tells
/// the system that we want some separation between the items being shared.
///
/// See usages in ReadableViewController for more info.
///
class ActivityItemSource: NSObject, UIActivityItemSource {
    private let item: Any

    init(_ item: Any) {
        self.item = item
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return item
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return item
    }
}
