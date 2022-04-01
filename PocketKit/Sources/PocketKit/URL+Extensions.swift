import Foundation


extension URL {
    var host: String? {
        guard let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let host = urlComponents.host else {
            return nil
        }

        let components = host.components(separatedBy: ".")
        let endIndex = max(components.index(components.count, offsetBy: -2), 0)
        let parsed = components[endIndex...]
        return parsed.joined(separator: ".")
    }
}
