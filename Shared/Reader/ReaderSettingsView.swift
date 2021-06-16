// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct ReaderSettingsView: View {
    private enum Constants {
        static let allowedAdjustments = -10...10
        static let allowedFontFamilies: [FontDescriptor.Family] = [.graphik, .blanco]
    }
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @EnvironmentObject
    private var settings: ReaderSettings
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Settings")) {
                    Picker("Font", selection: $settings.fontFamily) {
                        ForEach(0..<Constants.allowedFontFamilies.count) {
                            Text(Constants.allowedFontFamilies[$0].name)
                                .tag(Constants.allowedFontFamilies[$0])
                        }
                    }
                    
                    Stepper("Font Size",
                            value: $settings.fontSizeAdjustment,
                            in: Constants.allowedAdjustments,
                            step: 2)
                }
            }
            .navigationBarTitle("", displayMode: .inline)
            .toolbar {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
