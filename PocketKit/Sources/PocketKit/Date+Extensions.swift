// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


extension Date: RawRepresentable {
    private static let dateFormatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        return Self.dateFormatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        guard let date = Self.dateFormatter.date(from: rawValue) else {
            return nil
        }
        
        self = date
    }
}
