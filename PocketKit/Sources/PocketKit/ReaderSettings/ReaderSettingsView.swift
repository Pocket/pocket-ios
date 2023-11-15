// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization
import SharedPocketKit

struct ReaderSettingsView: View {
    @Environment(\.presentationMode)
    private var presentationMode
    @State private var dismissReason: DismissReason = .swipe
    @ObservedObject private var settings: ReaderSettings

    init(settings: ReaderSettings) {
        self.settings = settings
    }

    var body: some View {
        Form {
            Section(header: Text(Localization.displaySettings)) {
                Picker(Localization.font, selection: settings.$fontFamily) {
                    ForEach(settings.fontSet, id: \.rawValue) { family in
                        Text(family.rawValue)
                            .tag(family)
                    }.navigationBarTitleDisplayMode(.inline)
                }

                Stepper(
                    Localization.fontSize,
                    value: settings.$fontSizeAdjustment,
                    in: settings.fontSizeAdjustmentRange,
                    step: settings.fontSizeAdjustmentStep
                )
                .accessibilityIdentifier("reader-settings-font-size-stepper")
                if settings.isPremium {
                    Stepper(
                        "Line Height",
                        value: settings.$lineHeightScaleFactorIndex,
                        in: settings.settingIndexRange,
                        step: settings.settingIndexStep
                    )
                    .accessibilityIdentifier("reader-settings-line-height-stepper")
                    Stepper(
                        "Margins",
                        value: settings.$marginsIndex,
                        in: settings.settingIndexRange,
                        step: settings.settingIndexStep
                    )
                    .accessibilityIdentifier("reader-settings-margins-stepper")
                } else {
                    SettingsRowButton(
                        title: "Unlock more options",
                        titleStyle: .settings.row.active,
                        leadingImageAsset: .premiumIcon,
                        leadingTintColor: Color(.ui.teal2)
                    ) {
                        settings.presentPremiumUpgrade()
                    }
                    .sheet(
                        isPresented: $settings.isPresentingPremiumUpgrade,
                        onDismiss: {
                            settings.trackPremiumDismissed(dismissReason: dismissReason)
                            if dismissReason == .system {
                                settings.isPresentingHooray = true
                            }
                        }
                    ) {
                        PremiumUpgradeView(dismissReason: self.$dismissReason, viewModel: settings.makePremiumUpgradeViewModel())
                    }
                    .task {
                        settings.trackPremiumUpsellViewed()
                    }
                }
            }
            .sheet(isPresented: $settings.isPresentingHooray) {
                PremiumUpgradeSuccessView()
            }
            if settings.isPremium {
                Section {
                    Button {
                        settings.reset()
                    } label: {
                        HStack {
                            Text("Reset to defaults")
                            Spacer()
                            if settings.isUsingDefaults {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundColor(Color(.ui.black1))
                }
            }
        }
    }
}
