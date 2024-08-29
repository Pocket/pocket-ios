// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

/// Events triggered by Pocket Intents used for app shortcuts, Siri and Apple Intelligence
public extension Events {
    struct PocketIntents {}
}

public extension Events.PocketIntents {
    /// The search saves intent was triggered
    static func searchSavesIntentCalled(_ criteria: String) -> Engagement {
        Engagement(uiEntity: UiEntity(.screen, identifier: "intents.searchSaves", value: criteria))
    }
}
