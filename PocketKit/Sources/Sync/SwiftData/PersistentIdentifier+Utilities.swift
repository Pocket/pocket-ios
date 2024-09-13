// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftData

/// Extract the uriRepresentation of an object, that can be used to retrieve the Core Data `NSManagedObjectID`
extension PersistentIdentifier {
    /// Extract `PersistentIdentifier` underlying values
    private struct Representation: Decodable {
        let uriRepresentation: String
        let primarykey: String
        let entityname: String

        enum CodingKeys: String, CodingKey {
            case implementation
        }

        enum ImbplementationCodingKeys: String, CodingKey {
            case uriRepresentation, primaryKey, entityName
        }

        func entityUrl() throws -> URL {
            guard let uri = URL(string: uriRepresentation) else {
                throw RepresentationError.invalidUriRepresentation(self.uriRepresentation)
            }
            return uri
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let implementationContainer = try container.nestedContainer(keyedBy: ImbplementationCodingKeys.self, forKey: .implementation)

            self.uriRepresentation = try implementationContainer.decode(String.self, forKey: .uriRepresentation)
            self.entityname = try implementationContainer.decode(String.self, forKey: .entityName)
            self.primarykey = try implementationContainer.decode(String.self, forKey: .primaryKey)
        }
    }

    private enum RepresentationError: Error {
        case invalidUriRepresentation(String)
    }

    private func representation() throws -> Representation {
        let encoded = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(Representation.self, from: encoded)
    }

    /// URI representation of a SwiftData model
    /// - Returns: the URI, if a valid one was extracted.
    public func uriRepresentation() throws -> URL {
        try representation().entityUrl()
    }
}
