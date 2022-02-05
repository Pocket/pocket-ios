import Network


protocol NetworkPath {
    var status: NWPath.Status { get }
}

protocol NetworkPathMonitor {
    func start(queue: DispatchQueue)
    var currentNetworkPath: NetworkPath { get }
}

extension NWPath: NetworkPath {

}

extension NWPathMonitor: NetworkPathMonitor {
    var currentNetworkPath: NetworkPath {
        currentPath
    }
}
