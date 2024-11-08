// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import Network

@MainActor
final class NetworkMonitor: ObservableObject {
    private let monitor: NetworkPathMonitor

    @Published private(set) var status: NWPath.Status = .satisfied

    init() {
        self.monitor = NWPathMonitor()
        monitor.updateHandler = { [weak self] path in
            self?.status = path.status
        }
    }

    func start(queue: DispatchQueue? = nil) {
        /// **NOTE: if we don't use main, data races will occur when trying to write a published property, even if the class is not marked @MainActor
        let queue = queue ?? DispatchQueue.main
        monitor.start(queue: queue)
    }

    func cancel() {
        monitor.cancel()
    }
}
