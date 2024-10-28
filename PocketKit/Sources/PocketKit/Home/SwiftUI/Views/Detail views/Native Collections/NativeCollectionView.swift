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
        if let collection {
            CollectionStoriesView(
                slug: collection.slug,
                header: CollectionHeader(
                    title: collection.title,
                    intro: collection.intro,
                    numberOfItems: collection.stories.count,
                    author: getAuthors(from: collection)
                )
            )
        }
    }

    private func getAuthors(from collection: Collection) -> String {
        if let item = collection.item, let authors = item.authors?.compactMap({ $0.name }) {
            return authors.joined()
        } else {
            return collection.authors.compactMap({ $0.name }).joined()
        }
    }
}
