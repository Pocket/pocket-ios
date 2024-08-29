// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import AppIntents
import Localization
@preconcurrency import PocketKit

struct SearchSavesIntent: AppIntent {
    static var title: LocalizedStringResource = "intents.searchSaves.title"
    static var description = IntentDescription("intents.searchSaves.description")
    static var openAppWhenRun: Bool = true

    @Dependency private var mainViewModel: MainViewModel?
    @Dependency private var defaultSeatch: DefaultSearchViewModel

    @Parameter(title: "intents.searchSaves.criteria.title")
    var criteria: String

    static var parameterSummary: some ParameterSummary {
        Summary("intents.searchSaves.criteria.summary")
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        guard let mainViewModel else { return .result() }
        mainViewModel.selectSavesTabForIntent()
        defaultSeatch.searchIntentCriteria = criteria
        return .result()
    }
}
