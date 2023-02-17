import SwiftUI
import Textile

struct PremiumUpgradeSuccessView: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            dismissButton
            Image(uiImage: UIImage(asset: .premiumHooray))
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
            Text("Hooray!")
                .style(.title)
            Text("You’re officially a Pocket Premium member. Welcome to the new ad-free, customizable, permanent version of your Pocket. We think you’ll like it here.")
                .style(.paragraph)
            Button(action: {
                dismiss()
            }) {
                VStack {
                    Text("Back to Pocket")
                        .style(.button)
                }
            }
            .padding()
                .frame(maxWidth: .infinity, minHeight: 53)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.ui.coral2))
                )
                .padding([.leading, .trailing], 15)
            Spacer()
        }
    }

    private var dismissButton: some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(asset: .close).renderingMode(.template).foregroundColor(Color(.ui.grey5))
            }
            .padding(.top, 20)
            .padding([.leading, .trailing], 20)
        }
    }
}

private extension Style {
    static let title = Style.header.serif.title

    static let paragraph = Style.header.serif.p2.with(alignment: .center)

    static let button = Style.header.sansSerif.p3.with(color: .ui.white).with(weight: .medium)
}
