import SwiftUI

private let constants = ListItem.Constants.tags

extension Image {
    func tagIconStyle() -> some View {
        self
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: constants.icon.size, height: constants.icon.size)
            .foregroundColor(constants.icon.color)
            .padding(.trailing, constants.icon.padding)
    }
}

struct TagBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(constants.padding)
            .background(Rectangle().fill(constants.backgroundColor))
            .cornerRadius(constants.cornerRadius)
    }
}

extension View {
    func tagBodyStyle() -> some View {
        self.modifier(TagBodyStyle())
    }
}
