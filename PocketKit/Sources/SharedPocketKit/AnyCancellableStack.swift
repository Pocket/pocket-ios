// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine

/// A stack used to store sets of Combine subscriptions that can be pushed or popped
/// Useful for recursive calls containing sets of subscriptions
public typealias AnyCancellableStack = [Set<AnyCancellable>]
public typealias SubscriptionSet = Set<AnyCancellable>

public extension Array where Element == Set<AnyCancellable> {
    mutating func push(_ element: Element) {
        append(element)
    }

    mutating func pop() {
        removeLast()
    }

    mutating func empty() {
        removeAll()
    }
}
