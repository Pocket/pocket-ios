// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct SelectIconView: View {
    @StateObject var viewModel: SelectIconViewModel

    init(viewModel: SelectIconViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Form {
            Group {
                Section(header: Text(Localization.Settings.AppIcon.thematicIconSectionHeader).style(.settings.header)) {
                    HStack(spacing: 16) {
                        Image(PocketAppIcon.primary.previewName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .cornerRadius(12)
                        Text(PocketAppIcon.primary.description)
                        Spacer()
                        CheckboxView(isSelected: viewModel.selectedAppIcon == PocketAppIcon.primary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task {
                            await viewModel.updateAppIcon(to: PocketAppIcon.primary)
                            viewModel.trackIconSelected(PocketAppIcon.primary.analyticsName)
                        }
                    }
                }
                .textCase(nil)
                Section(header: Text(Localization.Settings.AppIcon.customIconSectionHeader).style(.settings.header)) {
                    List(PocketAppIcon.selectableIcons) { appIcon in
                        HStack(spacing: 16) {
                            Image(appIcon.previewName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 60, height: 60)
                                .cornerRadius(12)
                            Text(appIcon.description)
                            Spacer()
                            CheckboxView(isSelected: viewModel.selectedAppIcon == appIcon)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                await viewModel.updateAppIcon(to: appIcon)
                                viewModel.trackIconSelected(appIcon.analyticsName)
                            }
                        }
                    }
                }
            }
            .textCase(nil)
            .listRowBackground(Color(.ui.grey7))
        }
        .onAppear {
            viewModel.trackIconSelectorViewed()
        }
        .scrollContentBackground(.hidden)
        .background(Color(.ui.white1).ignoresSafeArea())
        .navigationBarTitle(Localization.Settings.AppIcon.title, displayMode: .large)
    }
}

struct CheckboxView: View {
    let isSelected: Bool

    var body: some View {
        if isSelected {
            Image(asset: .circleChecked)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
        }
    }
}
