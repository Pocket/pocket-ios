// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync

struct ItemRow: View {
    @ObservedObject
    private var item: Item
    
    @ObservedObject
    var remoteImageLoader: RemoteImageLoader

    init(item: Item, loader: RemoteImageLoader) {
        self.item = item
        self.remoteImageLoader = loader
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                Text(item.title ?? item.url?.absoluteString ?? "Missing Title")
                    .font(.body)
                Text(caption(item))
                    .font(.caption)
            }
            
            if  item.thumbnailURL != nil {
                Spacer()
                
                VStack {
                    RemoteImageView(loader: remoteImageLoader) {
                        Rectangle().foregroundColor(.gray)
                    }
                    .frame(width: 64, height: 64).cornerRadius(4)
                    Spacer()
                }
            }
        }
    }
    
    private func caption(_ item: Item) -> String {
        var components: [String] = []
        components.append(item.domain ?? "Missing Domain")
        if item.timeToRead > 0 {
            let timeToRead = "\(item.timeToRead) min"
            components.append(timeToRead)
        }
        return components.joined(separator: " • ")
    }
}
