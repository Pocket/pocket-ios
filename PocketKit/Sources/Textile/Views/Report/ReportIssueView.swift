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

    @Environment(\.dismiss)
    private var dismiss
    @State private var name = ""
    @State private var reportComment = ""

    private let email: String
    private var submitIssue: (String, String, String) -> Void

    public init(email: String, submitIssue: @escaping (String, String, String) -> Void) {
        self.email = email
        self.submitIssue = submitIssue
    }

    public var body: some View {
        Form {
            Section(header: Text(Localization.ReportIssue.header)) {
                Text(Localization.ReportIssue.description)
                    .style(.report.textStyle)
                    .padding([.top], Constants.padding)
                    .listRowBackground(Color.clear)
            }.listRowInsets(EdgeInsets())

            Section(
                header: ReportHeader(title: Localization.ReportIssue.email, isOptional: false)
            ) {
                Text(email)
                    .style(.report.textStyle.with(color: .ui.grey5))
                    .listRowBackground(Color.clear)
            }.listRowInsets(EdgeInsets())

            ReportField(
                userInput: $name,
                header: Localization.ReportIssue.name,
                height: Constants.defaultRowHeight
            )
            .accessibilityIdentifier("name-field")

            Section(
                header: ReportHeader(title: Localization.ReportIssue.comment)
            ) {
                TextEditor(text: $reportComment)
                    .style(.report.textStyle)
                    .padding()
                    .frame(height: Constants.commentRowHeight)
                    .overlay(RoundedRectangle(cornerRadius: Constants.cornerRadius).strokeBorder(Color.black, style: StrokeStyle(lineWidth: Constants.lineWidth)))
                    .accessibilityIdentifier("comment-section")
            }.listRowInsets(EdgeInsets())

            Button(action: {
                submitIssue(name, email, reportComment)
                dismiss()
            }) {
                Text(Localization.ReportIssue.SubmitIssue.title)
            }
            .listRowBackground(Rectangle().foregroundColor(.clear))
            .listRowInsets(EdgeInsets())
            .buttonStyle(PocketButtonStyle(.primary))
            .accessibilityIdentifier("submit-issue")
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
        ReportIssueView(
            email: "user@email.com",
            submitIssue: { _, email, _ in
                print(email)
            }
        )
        .previewDisplayName("Report Issue - Light")
        .preferredColorScheme(.light)

        ReportIssueView(
            email: "user@email.com",
            submitIssue: { _, email, _ in
                print(email)
            }
        )
        .previewDisplayName("Report Issue - Dark")
        .preferredColorScheme(.dark)

        ReportIssueView(
            email: "user@email.com",
            submitIssue: { _, email, _ in
                print(email)
            }
        )
        .previewDisplayName("Report Issue - Not Enabled")
        .preferredColorScheme(.light)
    }
}
