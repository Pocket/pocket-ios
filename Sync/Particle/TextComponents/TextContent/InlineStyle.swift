// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct InlineStyle: Equatable {
    public enum Style: Equatable, CaseIterable {
        case big
        case small
        case italic
        case bold
        case strike
        case strong
        case unsupported(String)

        public static var allCases: [InlineStyle.Style] = [
            .big,
            .small,
            .italic,
            .bold,
            .strike,
            .strong
        ]
    }

    public let start: Int
    public let length: Int
    public let style: Style

    public init(start: Int, length: Int, style: Style) {
        self.start = start
        self.length = length
        self.style = style
    }
}
