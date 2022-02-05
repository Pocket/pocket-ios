@testable import PocketKit
import Network


class MockNetworkPathMonitor: NetworkPathMonitor {
    var currentNetworkPath: NetworkPath

    init(path: Path = Path(status: .satisfied)) {
        self.currentNetworkPath = path
    }

    func start(queue: DispatchQueue) {

    }

    struct Path: NetworkPath {
        var status: NWPath.Status
    }
}
