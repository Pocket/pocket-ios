import Network
import Sync
import Combine

class PremiumUpgradeViewModel: ObservableObject {
    private let networkPathMonitor: NetworkPathMonitor
    var monthlyText: String = "Monthy"
    var monthyFee: String = "$5.99/monthy"
    var yearlyText: String = "Yearly"
    var yearlyFee: String = "$50.99/yearly"

    var isOffline: Bool {
        networkPathMonitor.currentNetworkPath.status == .unsatisfied
    }

    init(networkPathMonitor: NetworkPathMonitor) {
        self.networkPathMonitor = networkPathMonitor
        networkPathMonitor.start(queue: .global())
    }
}
