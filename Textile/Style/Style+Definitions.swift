// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

extension FontDescriptor.Family {
    static let graphik: Self = "Graphik LCG"
    static let blanco: Self = "Blanco OSF"
    static let doyle: Self = "Doyle"
}

extension FontDescriptor.Size {
    static let h1: Self = 48
    static let h2: Self = 40
    static let h3: Self = 33
    static let h4: Self = 28
    static let h5: Self = 23
    static let h6: Self = 19
    static let h7: Self = 16
    static let p1: Self = 23
    static let p2: Self = 19
    static let p3: Self = 16
    static let p4: Self = 14
    static let body: Self = 19
}

public extension Style {
    static let header = Header()
    static let body = Body()

    struct Header {
        let sansSerif = SansSerif()
        let serif = Serif()
        let display = Display()

        struct SansSerif {
            let h1 = Style(family: .graphik, size: .h1, weight: .semibold)
            let h2 = Style(family: .graphik, size: .h2, weight: .semibold)
            let h3 = Style(family: .graphik, size: .h3, weight: .semibold)
            let h4 = Style(family: .graphik, size: .h4, weight: .semibold)
            let h5 = Style(family: .graphik, size: .h5, weight: .semibold)
            let h6 = Style(family: .graphik, size: .h6, weight: .semibold)
            let h7 = Style(family: .graphik, size: .h7, weight: .semibold)
            let p1 = Style(family: .graphik, size: .p1, weight: .regular)
            let p2 = Style(family: .graphik, size: .p2, weight: .regular)
            let p3 = Style(family: .graphik, size: .p3, weight: .regular)
            let p4 = Style(family: .graphik, size: .p4, weight: .regular)
        }

        struct Serif {
            let h1 = Style(family: .blanco, size: .h1, weight: .bold)
            let h2 = Style(family: .blanco, size: .h2, weight: .bold)
            let h3 = Style(family: .blanco, size: .h3, weight: .bold)
            let h4 = Style(family: .blanco, size: .h4, weight: .bold)
            let h5 = Style(family: .blanco, size: .h5, weight: .bold)
            let h6 = Style(family: .blanco, size: .h6, weight: .bold)
            let p1 = Style(family: .blanco, size: .p1, weight: .regular)
            let p2 = Style(family: .blanco, size: .p2, weight: .regular)
            let p3 = Style(family: .blanco, size: .p3, weight: .regular)
            let p4 = Style(family: .blanco, size: .p4, weight: .regular)
        }
    }

    struct Display {
        let medium = Medium()
        let regular = Regular()

        struct Medium {
            let h1 = Style(family: .doyle, size: .h1, weight: .medium)
            let h2 = Style(family: .doyle, size: .h2, weight: .medium)
            let h3 = Style(family: .doyle, size: .h3, weight: .medium)
            let h4 = Style(family: .doyle, size: .h4, weight: .medium)
            let h5 = Style(family: .doyle, size: .h5, weight: .medium)
            let h6 = Style(family: .doyle, size: .h6, weight: .medium)
        }

        struct Regular {
            let h1 = Style(family: .doyle, size: .h1, weight: .regular)
            let h2 = Style(family: .doyle, size: .h2, weight: .regular)
            let h3 = Style(family: .doyle, size: .h3, weight: .regular)
            let h4 = Style(family: .doyle, size: .h4, weight: .regular)
            let h5 = Style(family: .doyle, size: .h5, weight: .regular)
            let h6 = Style(family: .doyle, size: .h6, weight: .regular)
        }
    }

    struct Body {
        let sansSerif = Style(family:  .graphik, size: .body, weight: .regular)
        let serif = Style(family:  .blanco, size: .body, weight: .regular)
    }
}
