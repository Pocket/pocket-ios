// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct RemoteImageView<Placeholder: View>: View {
    private let placeholder: Placeholder
    
    @ObservedObject
    private var loader: RemoteImageLoader
    
    init(loader: RemoteImageLoader, @ViewBuilder placeholder: () -> Placeholder) {
        self.loader = loader
        self.placeholder = placeholder()
    }
    
    var body: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
        } else {
            placeholder
        }
    }
}
