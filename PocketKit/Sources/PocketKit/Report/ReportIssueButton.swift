// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import SharedPocketKit
import Textile

struct ReportIssueButton: View {
    @State var isPresentingReportIssue = false
    enum Constants {
        static let padding = EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)
        static let maxWidth: CGFloat = 320
    }

    private let text: String
    private let userEmail: String

    init(text: String, userEmail: String) {
        self.text = text
        self.userEmail = userEmail
    }

    var body: some View {
        Button(action: {
            isPresentingReportIssue.toggle()
        }, label: {
            Text(text)
                .style(.header.sansSerif.h7.with(color: .ui.white))
                .padding(Constants.padding)
                .frame(maxWidth: Constants.maxWidth)
        }).buttonStyle(PocketButtonStyle(.primary))
        .sheet(isPresented: $isPresentingReportIssue) {
            ReportIssueView(email: userEmail, submitIssue: submitIssue)
        }
        .accessibilityIdentifier("get-report-issue-button")
    }

    // Handle Sentry User Feedback Reporting
    private func submitIssue(name: String, email: String, comments: String) {
        Log.captureUserFeedback(message: "Report an issue", name: name, email: email, comments: comments)
    }
}
