// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct SelectIconView: View {
    @StateObject var viewModel = SelectIconViewModel()

    var body: some View {
        Form {
            Group {
                Section {
                    List(PocketAppIcon.allCases) { appIcon in
                        HStack(spacing: 16) {
                            Image(uiImage: appIcon.preview)
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
                            withAnimation {
                                viewModel.updateAppIcon(to: appIcon)
                            }
                        }
                    }
                }
                .listRowBackground(Color(.ui.grey7))
            }
        }
    }
}

struct SelectIconContainerView: View {
    var body: some View {
        SelectIconView()
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

#Preview {
    SelectIconView()
}
