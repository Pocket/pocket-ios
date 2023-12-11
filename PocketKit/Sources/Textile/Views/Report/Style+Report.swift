// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Style {
    static let report = ReportStyle()
    struct ReportStyle {
        let textStyle = Style.header.sansSerif.p3.with { paragraph in
            paragraph.with(lineSpacing: 4)
        }
    }
}
