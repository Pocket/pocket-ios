import Sync
import Network


class MockNetworkPathMonitor: NetworkPathMonitor {
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
