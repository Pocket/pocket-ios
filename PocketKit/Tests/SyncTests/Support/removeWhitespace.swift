// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

func removeWhitespace(_ data: Data?) -> String? {
    return data.flatMap {
        String(data: $0, encoding: .utf8)?
            .replacingOccurrences(
                of: #"[\n\s]"#,
                with: "",
                options: .regularExpression
            )
    }
}
