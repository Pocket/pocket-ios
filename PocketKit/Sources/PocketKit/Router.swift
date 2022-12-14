import Foundation
import Network
import Sync

class Router {
    private let source: Source

    init(source: Source) {
        self.source = source
    }

    func handle(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        if components.path == "/add" {
            guard let urlString = components.queryItems?.first(where: { $0.name == "url" })?.value,
                  let url = URL(string: urlString)
            else { return }

            saveItem(url: url)
        }
    }

    private func saveItem(url: URL) {
        source.save(url: url)
    }
}
