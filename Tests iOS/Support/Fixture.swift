// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import Sync


class Fixture {
    private enum DecodeError: Error {
        case invalidJSON
    }

    let data: Data

    init(data: Data) {
        self.data = data
    }

    static func load(name: String, ext: String = "json") -> Fixture {
        let bundle = Bundle(for: Self.self)
        guard let url = bundle.url(forResource: "Fixtures/\(name)", withExtension: ext) else {
            fatalError("Could not find fixture named \(name) in \(bundle)")
        }

        do {
            let data = try Data(contentsOf: url)
            return Fixture(data: data)
        } catch {
            fatalError("Could not load data from fixture named \(name) at url: \(url). Error: \(error)")
        }
    }

    static func data(name: String, ext: String = "json") -> Data {
        return load(name: name, ext: ext).data
    }
}
