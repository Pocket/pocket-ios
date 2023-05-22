// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SwiftUI

struct RecentSavesProvider: TimelineProvider {
    func placeholder(in context: Context) -> SavedItemEntry {
        SavedItemEntry(date: Date(), content: .placeHolder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SavedItemEntry) -> Void) {
        let entry = SavedItemEntry(date: Date(), content: .placeHolder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SavedItemEntry>) -> Void) {
        var entries: [SavedItemEntry] = []

        // TODO: populate entries here

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}
