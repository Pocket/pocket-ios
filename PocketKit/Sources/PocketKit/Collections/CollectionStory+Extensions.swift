// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync

extension CDCollectionStory {
    var isSaved: Bool {
        item?.savedItem != nil && item?.savedItem?.isArchived == false
    }

    var isCollection: Bool {
        item?.isCollection ?? CollectionUrlFormatter.isCollectionUrl(url)
    }
}
