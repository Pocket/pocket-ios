import SwiftUI
import Sync
import Analytics
import Textile


struct ReportRecommendationView: View {
    private struct Constants {
        static let cornerRadius: CGFloat = 4
        static let reasonRowHeight: CGFloat = 44
        static let reasonRowSelectedColor = Color(.ui.teal6)
        static let reasonRowDeselectedColor: Color = .clear
        static let reasonRowTint = Color(.ui.teal2)
        static let commentRowHeight: CGFloat = 92
        static let submitButtonHeight: CGFloat = 52
        static let submitButtonTintColor = Color(.ui.grey1)
        static let submitButtonBackgroundColor = Color(.ui.teal2)
    }
    
    private let recommendation: Slate.Recommendation
    private let tracker: Tracker
    
    private var submitAccessibilityIdentifier: String {
        selectedReason == nil ? "submit-report-disabled" : "submit-report"
    }
    
    @Environment(\.dismiss)
    private var dismiss
    
    @State
    private var selectedReason: ReportEvent.Reason? = nil
    
    @State
    private var reportComment = ""
    
    @State
    private var isReported = false
    
    @FocusState
    private var isCommentFocused: Bool

    init(recommendation: Slate.Recommendation, tracker: Tracker) {
        self.recommendation = recommendation
        self.tracker = tracker
    }
    
    var body: some View {
        List {
            Section(header: Text("Report a concern")) {
                ForEach(ReportEvent.Reason.allCases, id: \.self) { reason in
                    ReportReasonRow(
                        text: reason.displayString,
                        isSelected: reason == selectedReason) {
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
                    HStack {
                        Spacer()
                        Text(isReported ? "Reported" : "Submit feedback")
                            .style(Style.submitButtonStyle)
                        Spacer()
                    }
                }
                .frame(height: Constants.submitButtonHeight)
                .tint(Constants.submitButtonTintColor)
                .background(Constants.submitButtonBackgroundColor)
                .cornerRadius(Constants.cornerRadius)
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
    
    private func report(_ reason: ReportEvent.Reason) {
        guard let url = url(for: recommendation) else {
            return
        }

        let button = UIContext.button(identifier: .submit)
        let content = ContentContext(url: url)
        let comment = reportComment.isEmpty ? nil : reportComment
        let report = ReportEvent(reason: reason, comment: comment)
        let engagement = SnowplowEngagement(type: .report, value: nil)
        tracker.track(event: engagement, [button, content, report])
        
        isReported = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            dismiss()
        }
    }
    
    private func url(for recommendation: Slate.Recommendation) -> URL? {
        recommendation.item.resolvedURL ?? recommendation.item.givenURL
    }
    
    private func selectionColor(for reason: ReportEvent.Reason) -> Color {
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
    private struct Constants {
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
    private struct Constants {
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
                Text("Tell us more")
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
    static let submitButtonStyle = Style.header.sansSerif.h6.with(color: .ui.white)
}

private extension ReportEvent.Reason {
    var displayString: String {
        switch self {
        case .brokenMeta: return "The title, link, or image is broken"
        case .wrongCategory: return "It's in the wrong category"
        case .sexuallyExplicit: return "It's sexually explicit"
        case .offensive: return "It's rude, vulgar, or offensive"
        case .misinformation: return "It contains misinformation"
        case .other: return "Other"
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
