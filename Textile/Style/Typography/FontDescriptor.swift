// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct FontDescriptor {
    let family: Family?
    let size: Size?
    let weight: Weight?
    let slant: Slant?

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
        family: Family? = nil,
        size: Size? = nil,
        weight: Weight? = nil,
        slant: Slant? = nil
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
        guard let size = size else {
            return self
        }
        
        let adjusted = size.size + adjustment
        let adjustedSize = Size(size: adjusted)
        return FontDescriptor(family: family, size: adjustedSize, weight: weight, slant: slant)
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
