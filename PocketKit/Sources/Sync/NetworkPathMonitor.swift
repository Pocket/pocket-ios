import Network


public protocol NetworkPath {
    var status: NWPath.Status { get }
}

public protocol NetworkPathMonitor: AnyObject {
    typealias UpdateHandler = (NetworkPath) -> Void

    var currentNetworkPath: NetworkPath { get }
    var updateHandler: UpdateHandler? { get set }

    func start(queue: DispatchQueue)
}

extension NWPath: NetworkPath {

}

extension NWPathMonitor: NetworkPathMonitor {
    public var currentNetworkPath: NetworkPath {
        currentPath
    }

    public var updateHandler: UpdateHandler? {
        get {
            return { (path: NetworkPath) in
                guard let nwpath = path as? NWPath else {
                    fatalError("Attempt to use \(path) as path for real \(Self.self). This is not allowed")
                }

                self.pathUpdateHandler?(nwpath)
            }
        }

        set { pathUpdateHandler = newValue }
    }
}
