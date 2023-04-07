// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation

/// An `Identifiable` type containing a title and a text
/// Useful for SwiftUI lists like the subscription status list
struct LabeledText: Identifiable {
    var id = UUID()
    let title: String
    let text: String
}
