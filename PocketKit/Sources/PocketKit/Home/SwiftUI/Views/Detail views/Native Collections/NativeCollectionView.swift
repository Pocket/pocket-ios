// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct NativeCollectionView: View {
    let route: NativeCollectionRoute

    @Query private var collections: [Collection]
    private var collection: Collection? {
        collections.first
    }

    init(route: NativeCollectionRoute) {
        self.route = route
        var fetchDescriptor = FetchDescriptor(predicate: #Predicate<Collection> { $0.slug == route.slug })
        fetchDescriptor.fetchLimit = 1
        _collections = Query(fetchDescriptor)
    }

    var body: some View {
        // TODO: SWIFTUI - add implementation.
        Text("This will show the contents of the selected collection.")
    }
}
