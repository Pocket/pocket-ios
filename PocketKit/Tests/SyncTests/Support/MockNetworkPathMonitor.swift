// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import Network

class MockNetworkPathMonitor: NetworkPathMonitor {
    func cancel() {}

    var updateHandler: UpdateHandler?
    var currentNetworkPath: NetworkPath { path }

    private var path: Path
    private var startCalls: [StartCall] = []

    init(path: Path = Path(status: .satisfied)) {
        self.path = path
    }

    var wasStartCalled: Bool {
        !startCalls.isEmpty
    }

    func start(queue: DispatchQueue) {
        startCalls.append(StartCall(queue: queue))
    }

    func update(status: NWPath.Status) {
        path = Path(status: status)
        self.updateHandler?(self.path)
    }

    struct Path: NetworkPath {
        var status: NWPath.Status
    }

    struct StartCall {
        var queue: DispatchQueue
    }
}
