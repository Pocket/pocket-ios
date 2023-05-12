// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension URL {
    init?(percentEncoding string: String) {
        if let url = URL(string: string) {
            self = url
        } else if let escaped = string.addingPercentEncoding(withAllowedCharacters: .urlAllowed),
                  let url = URL(string: escaped) {
            self = url
        } else {
            return nil
        }
    }
}
