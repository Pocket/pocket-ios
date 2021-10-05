// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.s

import Foundation


extension UIContext {
    func with(hierarchy: UIHierarchy) -> UIContext {
        UIContext(
            type: type,
            hierarchy: hierarchy,
            identifier: identifier,
            componentDetail: componentDetail,
            index: index
        )
    }
}
