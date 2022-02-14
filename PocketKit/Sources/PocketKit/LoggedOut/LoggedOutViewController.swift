import UIKit
import Textile
import SwiftUI


class LoggedOutViewController: UIHostingController<LoggedOutView> {
    convenience init() {
        self.init(rootView: LoggedOutView())
    }
}

struct LoggedOutView: View {
    var body: some View {
        Group {
            Image(asset: .labeledIcon)

            Spacer()

            LoggedOutInfoView().padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))

            Spacer()

            LoggedOutActions()
        }
        .preferredColorScheme(.light)
        .padding(16)
    }
}

private struct LoggedOutInfoView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(asset: .loggedOutInfo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320)

            Text("Save what really interests you")
                .style(.header.sansSerif.h7)

            Text("Collect articles, videos or any online content you like.")
                .style(.header.sansSerif.p4.with(color: .ui.grey5).with { $0.with(lineSpacing: 6).with(alignment: .center) })
                .frame(maxWidth: 240)
        }
    }
}

private struct LoggedOutActions: View {
    var body: some View {
        VStack {
            Button {

            } label: {
                Text("Sign Up").style(.header.sansSerif.h7.with(color: .ui.white))
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .frame(maxWidth: 320)
            }.buttonStyle(LoggedOutButtonStyle())

            Button {

            } label: {
                Text("Log In")
                    .style(.header.sansSerif.p4)
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }
    }
}

private struct LoggedOutButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color(.ui.teal1) : Color(.ui.teal2))
            .cornerRadius(4)
    }
}
