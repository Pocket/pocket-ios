// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension InlineStyle: Decodable {
    private enum SupportedStyle: String {
        case big
        case small
        case italic = "i"
        case bold = "b"
        case strike
        case strong
    }

    private enum CodingKey: String, Swift.CodingKey {
        case style
        case start
        case length
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKey.self)

        self.start = try container.decode(Int.self, forKey: .start)
        self.length = try container.decode(Int.self, forKey: .length)
        let rawStyle = try container.decode(String.self, forKey: .style)
        self.style = {
            switch(SupportedStyle(rawValue: rawStyle)) {
            case .big:
                return .big
            case .small:
                return .small
            case .italic:
                return .italic
            case .bold:
                return .bold
            case .strike:
                return .strike
            case .strong:
                return .strong
            case .none:
                Crashlogger.capture(message: "Encountered unsupported \(InlineStyle.self) type: \(rawStyle)")
                return .unsupported(rawStyle)
            }
        }()
    }
}
