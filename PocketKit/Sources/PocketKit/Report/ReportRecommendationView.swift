// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Analytics
import Textile
import Localization
import SharedPocketKit

struct ReportRecommendationView: View {
    private enum Constants {
        static let cornerRadius: CGFloat = 4
        static let reasonRowHeight: CGFloat = 44
        static let reasonRowSelectedColor = Color(.ui.teal6)
        static let reasonRowDeselectedColor: Color = .clear
        static let reasonRowTint = Color(.ui.teal2)
        static let commentRowHeight: CGFloat = 92
    }

    private let recommendation: Recommendation
    private let tracker: Tracker

    private var submitAccessibilityIdentifier: String {
        selectedReason == nil ? "submit-report-disabled" : "submit-report"
    }

    @Environment(\.dismiss)
    private var dismiss

    @State private var selectedReason: ReportEntity.Reason?

    @State private var reportComment = ""

    @State private var isReported = false

    @FocusState private var isCommentFocused: Bool

    init(recommendation: Recommendation, tracker: Tracker) {
        self.recommendation = recommendation
        self.tracker = tracker
    }

    var body: some View {
        List {
            Section(header: Text(Localization.reportAConcern)) {
                ForEach(ReportEntity.Reason.allCases, id: \.self) { reason in
                    ReportReasonRow(
                        text: reason.localized,
                        isSelected: reason == selectedReason
                    ) {
                        guard reason != selectedReason else {
                            isCommentFocused = false
                            return
                        }

                        selectedReason = reason
                    }
                    .tint(Constants.reasonRowTint)
                    .frame(height: Constants.reasonRowHeight)
                    .listRowBackground(Rectangle().foregroundColor(selectionColor(for: reason)))
                    .listRowSeparator(.hidden)
                    .accessibilityIdentifier(reason.accessibilityIdentifier)
                }

                if selectedReason == .other {
                    ReportCommentRow(text: $reportComment, isFocused: $isCommentFocused)
                        .frame(height: Constants.commentRowHeight)
                        .listRowBackground(Rectangle().foregroundColor(.clear))
                        .listRowSeparator(.hidden)
                }

                Button(action: submitReport) {
                    Text(isReported ? Localization.reported : Localization.submitFeedback)
                }.buttonStyle(PocketButtonStyle(.primary))
                .padding()
                .listRowBackground(Rectangle().foregroundColor(.clear))
                .listRowSeparator(.hidden)
                .disabled(selectedReason == nil)
                .accessibilityIdentifier(submitAccessibilityIdentifier)
            }
        }
        .listStyle(.grouped)
        .edgesIgnoringSafeArea([])
        .disabled(isReported == true)
        .accessibilityIdentifier("report-recommendation")
    }

    private func report(_ reason: ReportEntity.Reason) {
        let comment = reportComment.isEmpty ? nil : reportComment

        isReported = true

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            dismiss()
        }
        let item = recommendation.item

        // NOTE: As of 2/17/2023 The report view can only be called from the Home screen, so we assume that the SlateArticleReport event is the correct one.
        guard let givenURL = URL(string: item.givenURL) else { return }
        tracker.track(event: Events.Home.SlateArticleReport(url: givenURL, reason: reason, comment: comment))
    }

    private func selectionColor(for reason: ReportEntity.Reason) -> Color {
        return reason == selectedReason ? Constants.reasonRowSelectedColor : Constants.reasonRowDeselectedColor
    }

    private func submitReport() {
        isCommentFocused = false

        guard let reason = self.selectedReason else {
            return
        }
        self.report(reason)
    }
}

private struct ReportReasonRow: View {
    private enum Constants {
        static let contentSpacing: CGFloat = 12
    }

    private let text: String
    private let isSelected: Bool
    private let action: () -> Void

    init(text: String, isSelected: Bool, action: @escaping () -> Void) {
        self.text = text
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.contentSpacing) {
                Image(asset: isSelected ? .radioSelected : .radioDeselected)
                Text(text).style(.recommendationRowStyle)
            }
        }
    }
}

private struct ReportCommentRow: View {
    private enum Constants {
        static let placeholderPadding = EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0)
        static let placeholderOpacity: CGFloat = 0.5
        static let padding: CGFloat = 8
        static let cornerRadius: CGFloat = 4
        static let strokeColor = Color(.ui.grey1)
        static let lineWidth: CGFloat = 1
        static let accessibilityIdentifier = "report-comment"
    }

    var text: Binding<String>

    var isFocused: FocusState<Bool>.Binding

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty && isFocused.wrappedValue == false {
                Text(Localization.tellUsMore)
                    .style(.recommendationRowStyle)
                    .padding(Constants.placeholderPadding)
                    .opacity(Constants.placeholderOpacity)
            }

            TextEditor(text: text)
                .style(.recommendationRowStyle)
                .focused(isFocused)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.cornerRadius)
                        .stroke(Constants.strokeColor, lineWidth: Constants.lineWidth)
                )
                .accessibilityIdentifier(Constants.accessibilityIdentifier)
        }.padding([.top, .bottom], Constants.padding)
    }
}

private extension Style {
    static let recommendationRowStyle = Style.header.sansSerif.p3
}

private extension ReportEntity.Reason {
    var localized: String {
        switch self {
        case .brokenMeta: return Localization.theTitleLinkOrImageIsBroken
        case .wrongCategory: return Localization.itSInTheWrongCategory
        case .sexuallyExplicit: return Localization.itSSexuallyExplicit
        case .offensive: return Localization.itSRudeVulgarOrOffensive
        case .misinformation: return Localization.itContainsMisinformation
        case .other: return Localization.other
        }
    }

    var accessibilityIdentifier: String {
        switch self {
        case .brokenMeta: return "broken-meta"
        case .wrongCategory: return "wrong-category"
        case .sexuallyExplicit: return "sexually-explicit"
        case .offensive: return "offensive"
        case .misinformation: return "misinformation"
        case .other: return "other"
        }
    }
}
