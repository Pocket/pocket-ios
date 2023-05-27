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
        var entry: RecentSavesEntry
        do {
            try entry = getEntry(for: context.family)
        } catch {
            Log.capture(message: "Unable to read saved items from shared useer defaults")
            entry = RecentSavesEntry(date: Date(), content: [.placeHolder])
        }
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<RecentSavesEntry>) -> Void) {
        var entries = [RecentSavesEntry]()

        do {
            let entry = try getEntry(for: context.family)
            entries = [entry]
        } catch {
            Log.capture(message: "Unable to read saved items from shared useer defaults")
            // TODO: Handle error scenario here
        }

        let timeline = Timeline(entries: entries, policy: .never)
        completion(timeline)
    }

    private func numberOfItems(for widgetFamily: WidgetFamily) -> Int {
        switch widgetFamily {
        case .systemExtraLarge:
            return 0
        case .systemLarge:
            return 4
        case .systemMedium:
            return 2
        default:
            return 1
        }
    }

    private func getEntry(for widgetFamily: WidgetFamily) throws -> RecentSavesEntry {
        guard let defaults = UserDefaults(suiteName: "group.com.ideashower.ReadItLaterPro") else {
            throw RecentSavesProviderError.invalidStore
        }
        let service = RecentSavesWidgetService(store: RecentSavesWidgetStore(userDefaults: defaults))

        return RecentSavesEntry(date: Date(), content: service.getRecentSaves(limit: numberOfItems(for: widgetFamily)))
    }
}
