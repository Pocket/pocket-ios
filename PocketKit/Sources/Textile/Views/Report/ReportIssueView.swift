// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Localization

public struct ReportIssueView: View {
    private struct Constants {
        static let cornerRadius: CGFloat = 10
        static let defaultRowHeight: CGFloat = 50
        static let commentRowHeight: CGFloat = 124
        static let padding: CGFloat = 8
        static let strokeColor = Color(.ui.grey1)
        static let lineWidth: CGFloat = 1
    }

    private var submitIssue: (String, String, String) -> Void

    public init(userEmail: String, submitIssue: @escaping (String, String, String) -> Void) {
        _email = State(initialValue: userEmail)
        self.submitIssue = submitIssue
    }

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email: String
    @State private var reportComment = ""

    public var body: some View {
        Form {
            Section(header: Text(Localization.ReportIssue.header)) {
                Text(Localization.ReportIssue.description)
                    .style(.recommendation.textStyle)
                    .padding([.top], Constants.padding)
                    .listRowBackground(Color.clear)
            }.listRowInsets(EdgeInsets())

            ReportField(userInput: $name, header: Localization.ReportIssue.name, height: Constants.defaultRowHeight)

            ReportField(userInput: $email, header: Localization.ReportIssue.email, height: Constants.defaultRowHeight)

            Section(header: Text(Localization.ReportIssue.comment).style(.recommendation.textStyle).textCase(nil)) {
                TextEditor(text: $reportComment)
                    .style(.recommendation.textStyle)
                    .padding()
                    .frame(height: Constants.commentRowHeight)
                    .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius).strokeBorder(Color.black, style: StrokeStyle(lineWidth: Constants.lineWidth)))
            }.listRowInsets(EdgeInsets())

            Button(action: {
                submitIssue(name, email, reportComment)
                dismiss()
            }) {
                Text(Localization.ReportIssue.submitIssue)
            }
            .listRowBackground(Rectangle().foregroundColor(.clear))
            .listRowInsets(EdgeInsets())
            .buttonStyle(PocketButtonStyle(.primary))
        }
        .padding([.top, .bottom], Constants.padding)
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .accessibilityIdentifier("report-issue")
    }
}

struct ReportIssueView_PreviewProvider: PreviewProvider {
    static var previews: some View {
        ReportIssueView(userEmail: "user@email.com", submitIssue: { _, email, _ in
            print(email)
            })
            .previewDisplayName("Report Issue - Light")
            .preferredColorScheme(.light)

        ReportIssueView(userEmail: "user@email.com", submitIssue: { _, email, _ in
            print(email)
        })
            .previewDisplayName("Report Issue - Dark")
            .preferredColorScheme(.dark)
    }
}
