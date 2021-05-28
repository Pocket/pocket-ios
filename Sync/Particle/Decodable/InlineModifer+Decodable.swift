// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension InlineModifier: Decodable {
    private enum InlineModifierType: String, Decodable {
        case link = "InlineLink"
        case style = "InlineStyle"
    }

    private enum InlineModifierTypeKey: String, CodingKey {
        case type = "_type"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: InlineModifierTypeKey.self)
        let typeString = try container.decode(String.self, forKey: .type)
        guard let type = InlineModifierType(rawValue: typeString) else {
            self = .unsupported(typeString)
            return
        }

        switch type {
        case .link:
            self = try .link(InlineLink(from: decoder))
        case .style:
            self = try .style(InlineStyle(from: decoder))
        }
    }
}
