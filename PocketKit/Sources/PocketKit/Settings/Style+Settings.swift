import Textile


extension Style {
    struct Settings {
//        let `default`: Style = Style.header.sansSerif.p3.with(color: .ui.black)
        let sectionHeader: Style = Style.header.sansSerif.h7.with(color: .ui.black)
        let row: Style = Style.header.sansSerif.p3.with(color: .ui.black)
        let signOut: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.apricot1)
    }
    
    static let settings = Settings()
}
