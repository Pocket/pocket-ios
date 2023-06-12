// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Sync

class AddSavedItemModel {
    let source: Source

    init(source: Source) {
        self.source = source
    }

    func saveURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false
        }

        source.save(url: url)
        return true
    }
}

struct AddSavedItem: View {
    @Environment(\.dismiss) var dismiss
    @State private var urlString: String = ""
    @State private var showError: Bool = false

    private let model: AddSavedItemModel

    init(model: AddSavedItemModel) {
        self.model = model
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 50) {
                Text("Add a URL")
                    .style(.header.sansSerif.title.with(weight: .semibold))
                VStack {
                    URLEntryTextField()
                    if showError {
                        HStack {
                            Text("Please enter a valid URL")
                                .foregroundColor(.red)
                                .style(.header.sansSerif.p4.with(weight: .bold))
                            Spacer()
                        }
                    }
                }
                VStack(spacing: 30) {
                    Button("Save to Pocket") {
                        self.submitItem()
                    }
                    .buttonStyle(PocketButtonStyle(.primary))
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(PocketButtonStyle(.secondary))
                }
                Spacer()
            }.padding(16)
            .navigationBarItems(
                trailing:
                Button(action: {
                    dismiss()
                }) {
                    Text("Close")
                }.accessibilityIdentifier("close")
            )
        }
    }

    func submitItem() {
        guard model.saveURL(urlString) else {
            withAnimation {
                showError = true
            }
            return
        }

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

        return TextField("e.g. www.mozilla.com", text: binding)
            .textFieldStyle(.roundedBorder)
            .keyboardType(.URL)
            .textContentType(.URL)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
            .onSubmit {
                self.submitItem()
            }
    }
}

// struct AddSavedItem_Preview: PreviewProvider {
//    static var previews: some View {
//        AddSavedItem(model: AddSavedItemModel(source: MockSource()))
//    }
// }
