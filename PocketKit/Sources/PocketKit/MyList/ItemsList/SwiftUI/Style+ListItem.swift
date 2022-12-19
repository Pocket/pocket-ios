import Textile
import SwiftUI
import UIKit

extension Style {
    static let listItem = ListItem()
    struct ListItem {
        let title: Style = Style.header.sansSerif.h7.with(color: .ui.black1).with { paragraph in
            paragraph
                .with(lineSpacing: 4)
        }
        let detail: Style = Style.header.sansSerif.p4.with(weight: .regular).with(color: .ui.grey4)
        let tag: Style = Style.header.sansSerif.p5.with(weight: .medium).with(color: .ui.grey4)
        let tagCount: Style = Style.header.sansSerif.h7.with(color: .ui.grey4)
    }
}
