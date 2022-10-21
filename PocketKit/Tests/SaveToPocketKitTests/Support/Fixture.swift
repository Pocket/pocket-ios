// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Apollo
import ApolloAPI
import Sync

@testable import Sync

class Fixture {
    enum ReplacementEscapeStrategy {
        case none
        case encodeJSON
    }

    private enum DecodeError: Error {
        case invalidJSON
    }

    let data: Data
    let name: String
    let ext: String

    var string: String {
        guard let string = String(data: data, encoding: .utf8) else {
            fatalError("Could not decode string from fixture")
        }

        return string
    }

    init(name: String, ext: String, data: Data) {
        self.name = name
        self.ext = ext
        self.data = data
    }

    static func load(name: String, ext: String = "json") -> Fixture {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: "Fixtures/\(name)", withExtension: ext) else {
            fatalError("Could not find fixture named \(name) in \(bundle)")
        }

        do {
            let data = try Data(contentsOf: url)
            return Fixture(name: name, ext: ext, data: data)
        } catch {
            fatalError("Could not load data from fixture named \(name) at url: \(url). Error: \(error)")
        }
    }

    static func data(name: String, ext: String = "json") -> Data {
        return load(name: name, ext: ext).data
    }

    static func decode<T: Decodable>(name: String, ext: String = "json") -> T {
        let fixture = load(name: name, ext: ext)
        return fixture.decode()
    }

    func replacing(
        _ placeholder: String,
        withFixtureNamed fixtureName: String,
        escape: ReplacementEscapeStrategy = .none
    ) -> Fixture {
        let replacement = Fixture.load(name: fixtureName)
        return replacing(placeholder, with: replacement, escape: escape)
    }

    func replacing(
        _ placeholder: String,
        with fixture: Fixture,
        escape: ReplacementEscapeStrategy = .none
    ) -> Fixture {
        let replacement: String

        switch escape {
        case .none:
            replacement = fixture.string
        case .encodeJSON:
            let encoder = JSONEncoder()
            let data = try! encoder.encode(fixture.string)

            replacement = String(data: data, encoding: .utf8)!
        }

        let data = string
            .replacingOccurrences(of: "#\(placeholder)#", with: replacement)
            .data(using: .utf8)

        let newName = [name, fixture.name].joined(separator: "+")
        guard let data = data else {
            fatalError("Unable to encode \(newName) as utf8")
        }

        return Fixture(
            name: newName,
            ext: ext,
            data: data
        )
    }

    func asGraphQLResult<Operation: GraphQLOperation>(from operation: Operation) -> GraphQLResult<Operation.Data> {
        do {
            let anyJSON = try JSONSerialization.jsonObject(with: data, options: [])

            guard let jsonObject = anyJSON as? JSONObject else {
                throw DecodeError.invalidJSON
            }

            let response = GraphQLResponse(operation: operation, body: jsonObject)
            return try response.parseResultFast()
        } catch {
            fatalError("Could not decode graphQL result: \(error)")
        }
    }

    func decode<T: Decodable>(using decoder: JSONDecoder = JSONDecoder()) -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("\(error)")
        }
    }
}
