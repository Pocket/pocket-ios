// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct SettingsRowToggle: View {
    private var title: String
    private let action: (Bool) -> Void
    private let isOn: Binding<Bool>

    init(title: String, isOn: Binding<Bool>, action: @escaping (Bool) -> Void) {
        self.title = title
        self.isOn = isOn
        self.action = action
    }

    var body: some View {
        VStack {
            Toggle(title, isOn: isOn)
                .onChange(of: isOn.wrappedValue) { newValue in
                    self.action(newValue)
                }
        }
    }
}
