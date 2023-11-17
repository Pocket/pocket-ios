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
                CustomFontPicker(data: settings.fontSet, selection: settings.$fontFamily).navigationBarTitleDisplayMode(.inline)
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
                    SettingsRowButton(
                        title: Localization.Reader.Settings.premiumUpsellLabel,
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
}

import UIKit

struct CustomFontPicker: UIViewRepresentable {
    var data: [FontDescriptor.Family]
    @Binding var selection: FontDescriptor.Family

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.selectRow(data.firstIndex(of: selection) ?? 0, inComponent: 0, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: CustomFontPicker

        init(_ pickerView: CustomFontPicker) {
            self.parent = pickerView
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.data.count
        }

        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return parent.data[row].rawValue
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selection = parent.data[row]
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            var label = UILabel()
            if let v = view as? UILabel { label = v }

            if let font = UIFont(name: parent.data[row].name(for: .regular), size: 25) {
                label.font = font
            }

            label.text =  parent.data[row].rawValue
            label.textAlignment = .center
            return label
        }
    }
}
