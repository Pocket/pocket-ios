import Textile

extension Style {
    struct Search {
        let header: Style = Style.header.sansSerif.p4.with(color: .ui.grey4)
        struct Row {
            let `default`: Style = Style.header.sansSerif.p3.with(weight: .medium).with(color: .ui.black1)
        }
        let row = Row()
    }
    static let search = Search()
}
