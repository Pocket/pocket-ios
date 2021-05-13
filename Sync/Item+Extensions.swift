// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


extension Item {
    typealias RemoteItem = UserByTokenQuery.Data.UserByToken.UserItem.Node.AsyncItem.Item
    
    func update(from remoteItem: RemoteItem) {
        title = remoteItem.title
        url = URL(string: remoteItem.givenUrl)
    }
}
