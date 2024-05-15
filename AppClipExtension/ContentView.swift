// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import StoreKit

struct ContentView: View {
    @State var presentingAppStoreOverlay = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
            // TODO: We should determine the logic to present this.
            Text(verbatim: "App Store Overlay")
                .hidden()
                .appStoreOverlay(isPresented: $presentingAppStoreOverlay) {
                    SKOverlay.AppClipConfiguration(position: .bottom)
                }
        }
        .onAppear {
            presentingAppStoreOverlay = true
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
