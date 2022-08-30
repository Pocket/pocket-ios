import Textile


extension Style {
    struct Settings {
        
        let header: Style = Style.header.sansSerif.h7.with(color: .ui.black)
        
        struct Row {
            let `default`: Style = Style.header.sansSerif.p3.with(color: .ui.black)
            let header: Style = Style.header.sansSerif.p5.with(weight: .medium).with(color: .ui.black)
            let deactivated: Style = Style.header.sansSerif.p3.with(color: .ui.grey4)
            let active: Style = Style.header.sansSerif.p3.with(color: .ui.teal2)
        }
        
        struct Button {
            let `default`: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.black)
            let signOut: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.apricot1)
        }
        
        let row = Row()
        let button = Button()
    }
    
    static let settings = Settings()
}
