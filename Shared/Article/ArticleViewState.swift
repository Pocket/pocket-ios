// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Foundation


class ArticleViewState: ObservableObject {
    @Published
    var url: URL? = nil {
        didSet {
            isNavigationLinkActive = url != nil
        }
    }

    @Published
    var isNavigationLinkActive: Bool = false
}
