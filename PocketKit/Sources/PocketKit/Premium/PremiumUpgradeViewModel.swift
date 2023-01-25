import Network
import Sync
import Combine

class PremiumUpgradeViewModel: ObservableObject {
    private let networkPathMonitor: NetworkPathMonitor

    var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    init(networkPathMonitor: NetworkPathMonitor) {
        self.networkPathMonitor = networkPathMonitor
        networkPathMonitor.start(queue: .global())
    }
}
