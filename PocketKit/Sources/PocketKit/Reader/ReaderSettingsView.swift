// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct ReaderSettingsView: View {
    private enum Constants {
        static let allowedAdjustments = -6...6
        static let adjustmentStep = 2
        static let allowedFontFamilies: [FontDescriptor.Family] = [.graphik, .blanco]
    }
    
    @Environment(\.presentationMode)
    private var presentationMode

    @ObservedObject
    private var settings: ReaderSettings

    init(settings: ReaderSettings) {
        self.settings = settings
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Display Settings")) {
                    Picker("Font", selection: settings.$fontFamily) {
                        ForEach(0..<Constants.allowedFontFamilies.count) {
                            Text(Constants.allowedFontFamilies[$0].name)
                                .tag(Constants.allowedFontFamilies[$0])
                        }
                    }
                    
                    Stepper(
                        "Font Size",
                        value: settings.$fontSizeAdjustment,
                        in: Constants.allowedAdjustments,
                        step: Constants.adjustmentStep
                    )
                }
            }
        }
    }
}

private extension Style {
    func with(settings: ReaderSettings) -> Style {
        self.with(family: settings.fontFamily).adjustingSize(by: settings.fontSizeAdjustment)
    }
}
