// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SwiftUI
import Textile
import Sync
import SharedPocketKit
import Localization

struct SelectableTopicWidget: Widget {
    let kind: String

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectTopicIntent.self, provider: <#T##AppIntentTimelineProvider#>, content: <#T##(_) -> View#>)
    }
}
