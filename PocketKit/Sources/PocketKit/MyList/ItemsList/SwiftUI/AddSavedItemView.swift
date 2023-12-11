// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Localization

struct AddSavedItemView: View {
    @Environment(\.dismiss)
    private var dismiss

    @State private var urlString: String = ""
    @State private var showError: Bool = false

    private let model: AddSavedItemViewModel

    init(model: AddSavedItemViewModel) {
        self.model = model
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Group {
                    Text(Localization.Saves.AddSavedItem.title)
                        .style(.header.sansSerif.h2.with(weight: .semibold))
                }
                VStack {
                    URLEntryTextField()
                    if showError {
                        HStack {
                            Text(Localization.Saves.AddSavedItem.error)
                                .foregroundColor(.red)
                                .style(.header.sansSerif.p4.with(weight: .medium))
                                .accessibilityIdentifier("error_message")
                            Spacer()
                        }
                    }
                }
                VStack(spacing: 16) {
                    Button(Localization.Saves.AddSavedItem.addButton) {
                        Task { await self.submitItem() }
                    }
                    .buttonStyle(PocketButtonStyle(.primary))
                    .accessibilityIdentifier("add_item_button")

                    Button(Localization.Saves.AddSavedItem.cancel) {
                        userDidDismissView()
                    }
                    .buttonStyle(PocketButtonStyle(.secondary))
                    .accessibilityIdentifier("cancel_button")
                }
                Spacer()
            }
            .padding(16)
            .navigationBarItems(
                trailing:
                Button(action: {
                    userDidDismissView()
                }) {
                    Text(Localization.Saves.AddSavedItem.close)
                }.accessibilityIdentifier("close_button")
            )
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    @MainActor
    func submitItem() async {
        let saved = await model.saveURL(urlString)
        guard saved == true else {
            withAnimation {
                showError = true
            }
            return
        }

        dismiss()
    }

    func userDidDismissView() {
        model.trackUserDidDismissView()
        dismiss()
    }

    private func URLEntryTextField() -> some View {
        let binding = Binding<String>(get: {
            self.urlString
        }, set: {
            self.urlString = $0
            withAnimation {
                self.showError = false
            }
        })

        return TextField(Localization.Saves.AddSavedItem.placeholder, text: binding)
            .frame(height: 44)
            .background(Color(.ui.grey7))
            .padding([.leading, .trailing], 16)
            .background(
                RoundedRectangle(cornerRadius: 4).fill(Color(.ui.grey7))
            )
            .keyboardType(.URL)
            .textContentType(.URL)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .onSubmit {
                Task { await self.submitItem() }
            }.accessibilityIdentifier("url_textfield")
    }
}
