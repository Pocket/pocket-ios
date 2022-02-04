import SwiftUI
import Analytics
import Sync


class ReportRecommendationHostingController: OnDismissHostingController<ReportRecommendationView> {
    init(
        recommendation: Slate.Recommendation,
        tracker: Tracker,
        onDismiss: @escaping () -> Void
    ) {
        let view = ReportRecommendationView(
            recommendation: recommendation,
            tracker: tracker
        )
        super.init(rootView: view, onDismiss: onDismiss)
        
        UITableView.appearance(whenContainedInInstancesOf: [Self.self]).backgroundColor = UIColor(.ui.white1)
        UITextView.appearance(whenContainedInInstancesOf: [Self.self]).backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
