// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct ReaderSettingsView: View {
    private enum Constants {
        static let allowedAdjustments = -10...10
    }
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @EnvironmentObject
    private var settings: ReaderSettings
    
    @State
    private var selectedFontIndex = 0
    private var availableFonts = ["Graphik", "Blanco"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Settings")) {
                    Picker("Font", selection: $selectedFontIndex) {
                        ForEach(0..<availableFonts.count) {
                            Text(self.availableFonts[$0])
                        }
                    }
                    
                    Stepper("Font Size", value: $settings.fontSizeAdjustment, in: Constants.allowedAdjustments)
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
