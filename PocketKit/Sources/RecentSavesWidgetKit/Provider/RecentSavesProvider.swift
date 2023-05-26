// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import WidgetKit
import SharedPocketKit
import Sync

enum RecentSavesProviderError: Error {
    case invalidStore
}

/// Timeline provider for the recent saves widget
struct RecentSavesProvider: TimelineProvider {
    func placeholder(in context: Context) -> RecentSavesEntry {
        RecentSavesEntry(date: Date(), content: [.placeHolder])
    }

    func getSnapshot(in context: Context, completion: @escaping (RecentSavesEntry) -> Void) {
        // TODO: because recent saves are fetched locally, we might just want to show them in the snapshot as well

        let entry = RecentSavesEntry(date: Date(), content: [.placeHolder])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentSavesEntry>) -> Void) {
        var entries = [RecentSavesEntry]()

        do {
            let service = try makeRecentSavesService()
            entries = [RecentSavesEntry(date: Date(), content: service.getRecentSaves())]
        } catch {
            Log.capture(message: "Unable to read saved items from shared useer defaults")
            // TODO: Handle error scenario here
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    private func makeRecentSavesService() throws -> RecentSavesWidgetService {
        guard let defaults = UserDefaults(suiteName: "group.com.ideashower.ReadItLaterPro") else {
            throw RecentSavesProviderError.invalidStore
        }
        return RecentSavesWidgetService(store: RecentSavesWidgetStore(userDefaults: defaults))
    }
}
