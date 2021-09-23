// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import Foundation


class MainViewModel: ObservableObject {
    @Published
    var selectedSection: AppSection = .home

    @Published
    var selectedItem: Item?

    @Published
    var readerSettings = ReaderSettings()

    @Published
    var isCollapsed = false

    @Published
    var isPresentingReaderSettings = false

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var sharedActivity: PocketActivity?

    enum AppSection: CaseIterable, Identifiable {
        case home
        case myList

        var navigationTitle: String {
            switch self {
            case .home:
                return "Home"
            case .myList:
                return "My List"
            }
        }

        var id: AppSection {
            return self
        }
    }
}
