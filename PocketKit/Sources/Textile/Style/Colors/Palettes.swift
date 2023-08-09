// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

public struct UIPalette {
    public let apricot1 = ColorAsset.ui("apricot1")
    public let coral1 = ColorAsset.ui("coral1")
    public let coral2 = ColorAsset.ui("coral2")
    public let coral3 = ColorAsset.ui("coral3")
    public let coral4 = ColorAsset.ui("coral4")
    public let coral5 = ColorAsset.ui("coral5")

    public let grey1 = ColorAsset.ui("grey1")
    public let grey2 = ColorAsset.ui("grey2")
    public let grey3 = ColorAsset.ui("grey3")
    public let grey4 = ColorAsset.ui("grey4")
    public let grey5 = ColorAsset.ui("grey5")
    public let grey6 = ColorAsset.ui("grey6")
    public let grey7 = ColorAsset.ui("grey7")
    public let grey8 = ColorAsset.ui("grey8")

    public let homeCellBackground = ColorAsset.ui("homeCellBackground")
    public let saveButtonText = ColorAsset.ui("saveButtonText")
    public let textfieldURL = ColorAsset.ui("textfieldURL")

    public let lapis1 = ColorAsset.ui("lapis1")

    public let teal1 = ColorAsset.ui("teal1")
    public let teal2 = ColorAsset.ui("teal2")
    public let teal3 = ColorAsset.ui("teal3")
    public let teal4 = ColorAsset.ui("teal4")
    public let teal5 = ColorAsset.ui("teal5")
    public let teal6 = ColorAsset.ui("teal6")

    public let white = ColorAsset.ui("white")
    public let white1 = ColorAsset.ui("white1")

    public let black = ColorAsset.ui("black")
    public let black1 = ColorAsset.ui("black1")
    public let border = ColorAsset.ui("border")
    public let skeletonCellImageBackground = ColorAsset.ui("skeletonCellImageBackground")
}

public struct BrandingPalette {
    public let amber1 = ColorAsset.branding("amber1")
    public let amber2 = ColorAsset.branding("amber2")
    public let amber3 = ColorAsset.branding("amber3")
    public let amber4 = ColorAsset.branding("amber4")
    public let amber5 = ColorAsset.branding("amber5")

    public let apricot1 = ColorAsset.branding("apricot1")
    public let apricot2 = ColorAsset.branding("apricot2")
    public let apricot3 = ColorAsset.branding("apricot3")
    public let apricot4 = ColorAsset.branding("apricot4")
    public let apricot5 = ColorAsset.branding("apricot5")

    public let iris1 = ColorAsset.branding("iris1")
    public let iris2 = ColorAsset.branding("iris2")
    public let iris3 = ColorAsset.branding("iris3")
    public let iris4 = ColorAsset.branding("iris4")
    public let iris5 = ColorAsset.branding("iris5")

    public let lapis1 = ColorAsset.branding("lapis1")
    public let lapis2 = ColorAsset.branding("lapis2")
    public let lapis3 = ColorAsset.branding("lapis3")
    public let lapis4 = ColorAsset.branding("lapis4")
    public let lapis5 = ColorAsset.branding("lapis5")

    public let mint1 = ColorAsset.branding("mint1")
    public let mint2 = ColorAsset.branding("mint2")
    public let mint3 = ColorAsset.branding("mint3")
    public let mint4 = ColorAsset.branding("mint4")
    public let mint5 = ColorAsset.branding("mint5")
}

extension ColorAsset {
    public static let ui = UIPalette()
    public static let branding = BrandingPalette()
}
