// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreGraphics

extension NSAttributedString {
    func sizeFitting(
        availableWidth: CGFloat = .greatestFiniteMagnitude,
        availableHeight: CGFloat = .greatestFiniteMagnitude
    ) -> CGSize {
        guard !string.isEmpty else {
            return .zero
        }

        let rect = boundingRect(
            with: CGSize(width: availableWidth, height: availableHeight),
            options: [.usesFontLeading, .usesLineFragmentOrigin],
            context: nil
        )

        return CGSize(width: min(rect.width.rounded(.up), availableWidth), height: min(rect.height.rounded(.up), availableHeight))
    }
}
