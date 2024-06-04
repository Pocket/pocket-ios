// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension FontDescriptor.Size {
    static let title: Self = 36
    static let h1: Self = 32
    static let h2: Self = 28
    static let h3: Self = 25
    static let h4: Self = 23
    static let h5: Self = 21
    static let h6: Self = 20
    static let h7: Self = 17
    static let h8: Self = 16
    static let p1: Self = 20
    static let p2: Self = 19
    static let p3: Self = 16
    static let p4: Self = 14
    static let p5: Self = 12
    static let p6: Self = 11
    static let body: Self = 20
    static let monospace: Self = 14
}

public extension Style {
    static let header = Header()
    static let body = Body()

    struct Header: Sendable {
        public let sansSerif = Graphik()
        public let serif = GenericTextStyles(with: .blanco)
        public let display = Display()

        public func headerStyles(with family: FontDescriptor.Family) -> GenericTextStyles {
            GenericTextStyles(with: family)
        }

        public struct Graphik: Sendable {
            public let title = Style(family: .graphik, size: .title, weight: .medium)
            public let h1 = Style(family: .graphik, size: .h1, weight: .medium)
            public let h2 = Style(family: .graphik, size: .h2, weight: .medium)
            public let h3 = Style(family: .graphik, size: .h3, weight: .medium)
            public let h4 = Style(family: .graphik, size: .h4, weight: .medium)
            public let h5 = Style(family: .graphik, size: .h5, weight: .medium)
            public let h6 = Style(family: .graphik, size: .h6, weight: .medium)
            public let h7 = Style(family: .graphik, size: .h7, weight: .medium)
            public let h8 = Style(family: .graphik, size: .h8, weight: .medium)
            public let p1 = Style(family: .graphik, size: .p1, weight: .regular)
            public let p2 = Style(family: .graphik, size: .p2, weight: .regular)
            public let p3 = Style(family: .graphik, size: .p3, weight: .regular)
            public let p4 = Style(family: .graphik, size: .p4, weight: .regular)
            public let p5 = Style(family: .graphik, size: .p5, weight: .regular)
            // widgets
            public let p6 = Style(family: .graphik, size: .p6, weight: .regular)
            public let w8 = Style(family: .graphik, size: .p4, weight: .medium)
        }

        public struct GenericTextStyles: Sendable {
            public let title: Style
            public let h1: Style
            public let h2: Style
            public let h3: Style
            public let h4: Style
            public let h5: Style
            public let h6: Style
            public let p1: Style
            public let p2: Style
            public let p3: Style
            public let p4: Style
            public let p5: Style

            init(with family: FontDescriptor.Family) {
                title = Style(family: family, size: .title, weight: .bold)
                h1 = Style(family: family, size: .h1, weight: .bold)
                h2 = Style(family: family, size: .h2, weight: .bold)
                h3 = Style(family: family, size: .h3, weight: .bold)
                h4 = Style(family: family, size: .h4, weight: .bold)
                h5 = Style(family: family, size: .h5, weight: .bold)
                h6 = Style(family: family, size: .h6, weight: .bold)
                p1 = Style(family: family, size: .p1, weight: .regular)
                p2 = Style(family: family, size: .p2, weight: .regular)
                p3 = Style(family: family, size: .p3, weight: .regular)
                p4 = Style(family: family, size: .p4, weight: .regular)
                p5 = Style(family: family, size: .p5, weight: .regular)
            }
        }
    }

    struct Display: Sendable {
        public let medium = Medium()
        public let regular = Regular()

        public struct Medium: Sendable {
            public let h1 = Style(family: .doyle, size: .h1, weight: .medium)
            public let h2 = Style(family: .doyle, size: .h2, weight: .medium)
            public let h3 = Style(family: .doyle, size: .h3, weight: .medium)
            public let h4 = Style(family: .doyle, size: .h4, weight: .medium)
            public let h5 = Style(family: .doyle, size: .h5, weight: .medium)
            public let h6 = Style(family: .doyle, size: .h6, weight: .medium)
            public let h7 = Style(family: .doyle, size: .h7, weight: .medium)
            public let h8 = Style(family: .doyle, size: .h8, weight: .medium)
        }

        public struct Regular: Sendable {
            public let h1 = Style(family: .doyle, size: .h1, weight: .regular)
            public let h2 = Style(family: .doyle, size: .h2, weight: .regular)
            public let h3 = Style(family: .doyle, size: .h3, weight: .regular)
            public let h4 = Style(family: .doyle, size: .h4, weight: .regular)
            public let h5 = Style(family: .doyle, size: .h5, weight: .regular)
            public let h6 = Style(family: .doyle, size: .h6, weight: .regular)
        }
    }

    struct Body: Sendable {
        public let sansSerif = Style(family: .graphik, size: .body, weight: .regular)
        public let serif = Style(family: .blanco, size: .body, weight: .regular)
        public let monospace = Style(family: .monospace, size: .monospace, weight: .regular)

        public func bodyStyle(with family: FontDescriptor.Family) -> Style {
            Style(family: family, size: .body, weight: .regular)
        }
    }
}
