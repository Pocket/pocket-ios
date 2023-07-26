// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Analytics
import Sync

class ReportRecommendationHostingController: OnDismissHostingController<ReportRecommendationView> {
    init(
        givenURL: String,
        tracker: Tracker,
        onDismiss: @escaping () -> Void
    ) {
        let view = ReportRecommendationView(
            givenURL: givenURL,
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
