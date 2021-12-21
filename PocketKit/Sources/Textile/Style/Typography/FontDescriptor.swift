// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct FontDescriptor {
    let family: Family
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

    public struct Family: Hashable {
        public let name: String
        
        public init(name: String) {
            self.name = name
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

extension FontDescriptor.Family: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(name: value)
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
