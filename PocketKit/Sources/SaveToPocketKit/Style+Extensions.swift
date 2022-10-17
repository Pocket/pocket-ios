import Textile

extension Style {
    static let buttonText: Self = .header.sansSerif.h8.with(color: .ui.white)

    static func coloredMainText(color: ColorAsset) -> Style {
        .header.sansSerif.h2.with(color: color).with { $0.with(lineHeight: .explicit(36)).with(verticalAlignment: .center) }
    }
    static let mainText: Self = coloredMainText(color: .ui.teal2)
    static let mainTextError: Self = coloredMainText(color: .ui.coral2)

    static let detailText: Self = .header.sansSerif.p2.with { $0.with(lineHeight: .explicit(28)).with(alignment: .center) }

    static let dismiss: Self = .header.sansSerif.p4.with(color: .ui.grey5).with { $0.with(lineHeight: .explicit(22)) }
}
