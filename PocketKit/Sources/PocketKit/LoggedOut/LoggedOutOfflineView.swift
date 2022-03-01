import SwiftUI
import Textile


struct LoggedOutOfflineView: View {
    @Binding
    private var isPresented: Bool

    init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
    }

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }.tint(Color(.ui.grey6))
                }

                Spacer()
            }.padding(32)

            VStack {
                Spacer()

                LoggedOutOfflineInfoView()

                Spacer()
            }.padding(16)
        }
    }
}

private struct LoggedOutOfflineInfoView: View {
    var body: some View {
        VStack(spacing: 36) {
            Image(asset: .looking)

            VStack(spacing: 24) {
                Text("No Internet Connection")
                    .style(.main)

                Text("Looks like you're offline. Try checking your mobile data or wifi.")
                    .style(.detail)
            }
        }
    }
}

private extension Style {
    static let main: Self = .header.sansSerif.h2.with(weight: .bold)
    static let detail: Self = .header.sansSerif.p2.with { $0.with(alignment: .center).with(lineSpacing: 11) }
}
