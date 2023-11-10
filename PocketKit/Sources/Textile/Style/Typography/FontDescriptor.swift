// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct FontDescriptor {
    let family: Family
    let familyName: String
    let fontName: String?
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

        /// Font family name used by the system. In some cases family names can be different between regular and semibold weights
        /// - Parameter weight: the font weight
        /// - Returns: the family name
        public func name(for weight: Weight) -> String {
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
                return attribute(for: weight, regular: "IBM Plex Sans", strong: "IBM Plex Sans Semibold")
            case .zillaSlab:
                return attribute(for: weight, regular: "Zilla Slab", strong: "Zilla Slab Semibold")
            }
        }

        /// Font  name used by the system. In some cases font names can be different between regular and semibold weights
        /// - Parameter weight: the font weight
        /// - Returns: the font name
        public func fontName(for weight: Weight) -> String? {
            switch self {
            case .whitney:
                return attribute(for: weight, regular: "WhitneySSm-Book", strong: "WhitneySSm-Semibold")
            case .sentinel:
                return attribute(for: weight, regular: "SentinelSSm-Book", strong: "SentinelSSm-Semibold")
            case .idealSans:
                return attribute(for: weight, regular: "IdealSansSSm-Book", strong: "IdealSansSSm-Semibold")
            default:
                return nil
            }
        }

        private func attribute(for weight: Weight, regular: String, strong: String) -> String {
            if weight == .regular || weight == .medium {
                return regular
            } else {
                return strong
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
        self.familyName = family.name(for: weight)
        self.fontName = family.fontName(for: weight)
        self.size = size
        self.weight = weight
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
