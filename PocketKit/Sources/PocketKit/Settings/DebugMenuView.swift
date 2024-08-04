// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import SharedPocketKit

enum SnowplowEndpoint: String, CaseIterable, Identifiable {
    case production
    case mini
    case micro

    var id: Self { self }
}
struct DebugMenuView: View {
    @State private var selectedSnowplowEndpoint: SnowplowEndpoint = .micro
    @ObservedObject var viewModel: AccountViewModel
    let userIdentifier = Services.shared.appSession.currentSession?.userIdentifier ?? ""

    var body: some View {
        List {
            Section {
                SettingsRowButton(
                    title: "Reset to onboarding",
                    titleStyle: .settings.button.default,
                    icon: nil
                ) {
                    viewModel.signOut()
                }
            } header: {
                Text("Reset access state")
            } footer: {
                Text("Reset anonymous/authenticated back to onboarding.")
            }
            Section {
                DebugMenuRow(title: "user identifier", detail: userIdentifier)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = userIdentifier
                        }) {
                            Text("Copy to clipboard")
                            Image(systemName: "doc.on.doc")
                        }
                    }
            } header: {
                Text("User Details")
            } footer: {
                Text("Use context menu to copy the user identifier.")
            }

            Section {
                Picker("Snowplow endpoint", selection: $selectedSnowplowEndpoint) {
                    ForEach(SnowplowEndpoint.allCases) { type in
                        Text(type.rawValue.capitalized)
                    }
                }
                .onChange(of: selectedSnowplowEndpoint) { newValue in
                    // TODO: Add implementation to set snowplow endpoint based on selection
                }
            } header: {
                Text("Snowplow collector")
            } footer: {
                Text("This is used to change the snowplow endpoint to be used in the application.")
            }

            Section {
                ForEach(CurrentFeatureFlags.allCases, id: \.self) { featureFlag in
                    // TODO: Change to use toggle and force override for feature flags
                    DebugMenuRow(
                        title: featureFlag.rawValue,
                        detail: featureFlag.description,
                        value: Services.shared.featureFlagService.isAssigned(flag: featureFlag).description
                    )
                }
            } header: {
                Text("Feature Flags")
            } footer: {
                Text("This is used to view the feature flags details associated with this account.")
            }
        }
    }
}

struct DebugMenuRow: View {
    let title: String
    let detail: String
    let value: String

    init(title: String, detail: String = "", value: String = "") {
        self.title = title
        self.detail = detail
        self.value = value
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(value)
        }
    }
}
