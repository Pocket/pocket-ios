// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct FontDescriptor {
    let family: Family
    let fontName: String
    let size: Size
    let weight: Weight
    let slant: Slant

    public enum Weight {
        case regular
        case medium
        case semibold
        case bold
    }

    public enum Slant {
        case none
        case italic
    }

    public enum Family: String, Hashable {
        case graphik = "Graphik LCG"
        case blanco = "Blanco OSF"
        case doyle = "Doyle"
        case monospace = ".AppleSystemUIFontMonospaced"
        // premium fonts
        case idealSans = "Ideal Sans"
        case inter = "Inter"
        case plexSans = "Plex Sans"
        case sentinel = "Sentinel"
        case tiempos = "Tiempos"
        case vollkorn = "Vollkorn"
        case whitney = "Whitney"
        case zillaSlab = "Zilla Slab"

        public func fontName(for weight: Weight) -> String {
            switch self {
            case .graphik, .blanco, .doyle, .monospace, .inter, .tiempos, .vollkorn:
                return rawValue
            case .idealSans:
                return "Ideal Sans SSm"
            case .sentinel:
                return "Sentinel SSm"
            case .whitney:
                return "Whitney SSm"
            case .plexSans:
                if case .medium = weight, case .regular = weight {
                    return "IBM Plex Sans"
                } else {
                    return "IBM Plex Sans Semibold"
                }
            case .zillaSlab:
                if case .medium = weight, case .regular = weight {
                    return "Zilla Slab"
                } else {
                    return "Zilla Slab Semibold"
                }
            }
        }

        public func actualWeight(for weight: Weight) -> Weight {
            switch self {
                // downgrade the weight as these fonts are using a semibold variation
            case .plexSans, .zillaSlab:
                if case .semibold = weight {
                    return .regular
                }
                if case .bold = weight {
                    return .medium
                }
                return weight
            default:
                return weight
            }
        }
    }

    public struct Size {
        let size: Int
    }

    public init(
        family: Family = .graphik,
        size: Size = .body,
        weight: Weight = .regular,
        slant: Slant = .none
    ) {
        self.family = family
        self.fontName = family.fontName(for: weight)
        self.size = size
        self.weight = family.actualWeight(for: weight)
        self.slant = slant
    }

    func with(family: Family) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight, slant: slant)
    }

    func with(size: Size) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight, slant: slant)
    }

    func with(weight: Weight) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight, slant: slant)
    }

    func with(slant: Slant) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight, slant: slant)
    }

    func adjustingSize(by adjustment: Int) -> FontDescriptor {
        return FontDescriptor(family: family, size: size.adjusting(by: adjustment), weight: weight, slant: slant)
    }
}

extension FontDescriptor.Size: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(size: value)
    }
}

extension FontDescriptor.Size {
    public func adjusting(by adjustment: Int) -> FontDescriptor.Size {
        return FontDescriptor.Size(size: size + adjustment)
    }
}
