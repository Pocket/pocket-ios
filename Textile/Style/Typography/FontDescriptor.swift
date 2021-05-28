// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct FontDescriptor {
    let family: Family?
    let size: Size?
    let weight: Weight?

    public enum Weight {
        case regular
        case medium
        case semibold
        case bold
    }

    public struct Family {
        let name: String
    }

    public struct Size {
        let size: Int
    }

    func with(family: Family) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight)
    }

    func with(size: Size) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight)
    }

    func with(weight: Weight) -> FontDescriptor {
        FontDescriptor(family: family, size: size, weight: weight)
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
