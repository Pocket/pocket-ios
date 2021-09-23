// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension Source {
    public func refresh(maxItems: Int = 400) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            refresh(maxItems: maxItems) {
                continuation.resume(returning: ())
            }
        }
    }
}
