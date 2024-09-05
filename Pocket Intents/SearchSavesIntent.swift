// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AppIntents
import Localization
import PocketKit

/// Intent that enables search Pocket Saves via Siri or App Shortcuts
struct SearchSavesIntent: AppIntent {
    static var title: LocalizedStringResource = "intents.searchSaves.title"
    static var description = IntentDescription("intents.searchSaves.description")
    static var openAppWhenRun: Bool = true

    @Dependency private var mainViewModel: MainViewModel?
    @Dependency private var savesContainerViewModel: SavesContainerViewModel
    @Dependency private var defaultSeatch: DefaultSearchViewModel
    // this simple intent triggers the search in Pocket and uses
    // just a String as a parameter, not an AppEntity
    @Parameter(title: "intents.searchSaves.criteria.title")
    var criteria: String

    static var parameterSummary: some ParameterSummary {
        Summary("intents.searchSaves.criteria.summary")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let mainViewModel else { return .result() }
        mainViewModel.selectSavesTabForIntent()
        // for now we only support saves.
        savesContainerViewModel.selection = .saves
        defaultSeatch.searchIntentCriteria = criteria
        return .result()
    }
}
