// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization

struct ReaderSettingsView: View {
    private enum Constants {
        static let allowedAdjustments = -6...6
        static let adjustmentStep = 2
        static let allowedFontFamilies: [FontDescriptor.Family] = [.graphik, .blanco]
    }

    @Environment(\.presentationMode)
    private var presentationMode

    @ObservedObject private var settings: ReaderSettings

    init(settings: ReaderSettings) {
        self.settings = settings
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text(Localization.displaySettings)) {
                    Picker(Localization.font, selection: settings.$fontFamily) {
                        ForEach(Constants.allowedFontFamilies, id: \.name) { family in
                            Text(family.name)
                                .tag(family)
                        }.navigationBarTitleDisplayMode(.inline)
                    }

                    Stepper(
                        Localization.fontSize,
                        value: settings.$fontSizeAdjustment,
                        in: Constants.allowedAdjustments,
                        step: Constants.adjustmentStep
                    )
                    .accessibilityIdentifier("reader-settings-stepper")
                }
            }
            .navigationBarHidden(true)
        }
    }
}
