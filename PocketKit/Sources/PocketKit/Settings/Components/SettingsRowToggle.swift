// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

struct SettingsRowToggle: View {
    private var title: String

    @ObservedObject private var model: AccountViewModel

    let action: (Bool) -> Void

    init(title: String, model: AccountViewModel, action: @escaping (Bool) -> Void) {
        self.title = title
        self.model = model
        self.action = action
    }

    var body: some View {
        VStack {
            Toggle(title, isOn: model.$appBadgeToggle)
                .onChange(of: model.appBadgeToggle) { newValue in
                    self.action(newValue)
                }
        }
    }
}
