import SwiftUI
import Textile

struct PremiumStatusRow: View {
    var title: String

    let action: () -> Void

    var body: some View {
        Button {
            self.action()
        } label: {
            Text(title)
                .style(Style.itemTitle)
            Spacer()
            Image(uiImage: UIImage(asset: .chevronRight)).renderingMode(.template).foregroundColor(Color(.ui.black1))
        }
    }
}

private extension Style {
    static let itemTitle = Style.header.sansSerif.h7.with(weight: .regular)
}
