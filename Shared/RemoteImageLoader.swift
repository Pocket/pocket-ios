// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync

class RemoteImageLoader: ObservableObject {
    private var url: URL?
    
    private let session: URLSessionProtocol
    
    private var cancellable: URLSessionDataTaskProtocol? = nil
    
    @Published
    var image: UIImage? = nil
    
    init(url: URL?, session: URLSessionProtocol) {
        self.url = url
        self.session = session

        load()
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func load() {
        cancellable?.cancel()
        
        guard let url = url else {
            return
        }
        
        let request = URLRequest(url: url)
        cancellable = session.dataTask(with: request) { data, response, error in
            guard let response = response as? HTTPURLResponse,
                  (200...299).contains(response.statusCode),
                  let data = data else {
                return
            }
            
            if let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
        cancellable?.resume()
    }
}
