// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization

struct ReportHeader: View {
    var title: String
    var isOptional: Bool = true
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .style(.report.textStyle)
                .textCase(nil)
            if isOptional {
                Text(" - \(Localization.ReportIssue.optional)")
                    .style(.report.textStyle.with(slant: .italic))
                    .textCase(nil)
            }
        }
    }
}
