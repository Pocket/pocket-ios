// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

public struct TrackableView<T: View>: View {
    private var content: T

    @Environment(\.tracker)
    private var tracker: Tracker

    private var context: UIContext

    init(_ context: UIContext, _ content: () -> T) {
        self.content = content()
        self.context = context
    }

    public var body: some View {
        content.environment(\.tracker, tracker.childTracker(hosting: context))
    }
}

public extension View {
    @ViewBuilder
    func trackable(_ context: UIContext) -> TrackableView<Self> {
        TrackableView(context) { self }
    }
}
