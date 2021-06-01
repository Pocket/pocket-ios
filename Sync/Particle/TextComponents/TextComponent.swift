// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct TextComponent: Decodable, Hashable {
    public let text: TextContent

    public init(text: TextContent) {
        self.text = text
    }
}

public typealias BodyText = TextComponent
public typealias Byline = TextComponent
public typealias Copyright = TextComponent
public typealias Message = TextComponent
public typealias Pre = TextComponent
public typealias Quote = TextComponent
public typealias Title = TextComponent
