import Textile

extension Style {
    struct Settings {
        let header: Style = Style.header.sansSerif.h7.with(color: .ui.black1)

        struct Row {
            let `default`: Style = Style.header.sansSerif.p3.with(color: .ui.black1)
            let header: Style = Style.header.sansSerif.p5.with(weight: .medium).with(color: .ui.black1)
            let deactivated: Style = Style.header.sansSerif.p3.with(color: .ui.grey4)
            let active: Style = Style.header.sansSerif.p3.with(color: .ui.teal2)

            struct DarkBackground {
                let `default`: Style = Style.header.sansSerif.p3.with(color: .ui.white)
                let header: Style = Style.header.sansSerif.p5.with(weight: .medium).with(color: .ui.white)
            }
            let darkBackground = DarkBackground()
        }

        struct Button {
            let `default`: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.black1)
            let signOut: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.apricot1)
            let delete: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.apricot1)
            let darkBackground: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.white)
        }

        let row = Row()
        let button = Button()
    }

    static let settings = Settings()
}
