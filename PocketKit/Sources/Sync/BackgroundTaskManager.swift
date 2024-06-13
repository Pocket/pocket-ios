// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// NOTE: This protocol needs to be on the MainActor because we use to extend UIApplication
// and the related methods run on the MainActor
@MainActor
public protocol BackgroundTaskManager {
    func beginTask(withName name: String?, expirationHandler: (() -> Void)?) -> Int
    func endTask(_ identifier: Int)
}
