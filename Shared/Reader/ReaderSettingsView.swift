// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct ReaderSettingsView: View {
    @Environment(\.presentationMode)
    var presentationMode
    
    @State
    var selectedFontIndex = 0
    
    var availableFonts = ["Graphik", "Blanco"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Settings")) {
                    Picker("Font", selection: $selectedFontIndex) {
                        ForEach(0..<availableFonts.count) {
                            Text(self.availableFonts[$0])
                        }
                    }
                    
                    Stepper("Font size", onIncrement: nil, onDecrement: nil)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .toolbar {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
