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
            Section(header: Text(Localization.Reader.Settings.title)) {
                Picker(Localization.Reader.Settings.fontLabel, selection: settings.$fontFamily) {
                    ForEach(settings.fontSet, id: \.rawValue) { family in
                        Text(family.rawValue)
                            .tag(family)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
                Stepper(
                    Localization.Reader.Settings.fontSizeLabel,
                    value: settings.$fontSizeAdjustment,
                    in: settings.fontSizeAdjustmentRange,
                    step: settings.fontSizeAdjustmentStep
                )
                .accessibilityIdentifier("reader-settings-font-size-stepper")
                if settings.isPremium {
                    Stepper(
                        Localization.Reader.Settings.lineHeightLabel,
                        value: settings.$lineHeightScaleFactorIndex,
                        in: settings.settingIndexRange,
                        step: settings.settingIndexStep
                    )
                    .accessibilityIdentifier("reader-settings-line-height-stepper")
                    Stepper(
                        Localization.Reader.Settings.marginsLabel,
                        value: settings.$marginsIndex,
                        in: settings.settingIndexRange,
                        step: settings.settingIndexStep
                    )
                    .accessibilityIdentifier("reader-settings-margins-stepper")
                    Picker(Localization.Reader.Settings.alignmentLabel, selection: settings.$alignmentOption) {
                        ForEach(ReaderSettings.AlignmentOption.allCases, id: \.rawValue) { alignment in
                            Text(alignment.name)
                                .tag(alignment)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } else {
                    Button {
                        settings.presentPremiumUpgrade()
                    } label: {
                        HStack(alignment: .top, spacing: 0) {
                            VStack {
                                Image(uiImage: UIImage(asset: .premiumIcon))
                                    .renderingMode(.template)
                                    .foregroundColor(Color(.ui.teal2))
                                Spacer()
                            }
                            .padding(.trailing)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(Localization.Reader.Settings.premiumUpsellLabel)
                                    .style(.settings.row.active)
                                Text(Localization.Reader.Settings.premiumUpselSubtitle)
                                    .style(.settings.row.subtitle)
                            }
                        }
                        .padding(.top)
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
            Section {
                Button {
                    settings.reset()
                } label: {
                    HStack {
                        Text(Localization.Reader.Settings.resetToDefaultsLabel)
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
