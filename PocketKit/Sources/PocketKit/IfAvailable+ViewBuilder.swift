// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import SwiftUI

public extension View {
    /**
     *  Adds in the ability to use # available inline on views.
     *   view().modify {
     *      if #available(iOS 17.0, *) {
     *       $0.modelContainer(DataController.sharedModelContainer)
     *      }
     *   }
     */
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}
