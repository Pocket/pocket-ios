// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine

/// A stack used to store sets of Combine subscriptions that can be pushed or popped
/// Useful for recursive calls containing sets of subscriptions.
public struct SubscriptionsStack {
    private var sets: [Set<AnyCancellable>]

    public init() {
        self.sets = [Set<AnyCancellable>]()
    }

    public mutating func push(_ subscriptions: Set<AnyCancellable>) {
        sets.append(subscriptions)
    }

    /// Remove the last set of subscriptions from the stack
    public mutating func pop() {
        sets.removeLast()
    }

    /// Deletes the entire content of the stack
    public mutating func empty() {
        sets.removeAll()
    }
}
