// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SwiftUI

final class CellImpressionTracker: ObservableObject {
    @Published var cells: Set<HomeCardConfiguration> = []
    private var trackedCells: Set<HomeCardConfiguration> = []
    private var cellsDidUpdate: AnyCancellable?
    private let homeActions: HomeActions

    init() {
        self.homeActions = .init()
        cellsDidUpdate = $cells
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] cells in
            guard let self, cells != trackedCells else {
                return
            }
            let cellsToTrack = cells.subtracting(trackedCells)
            trackedCells = cells
            cellsToTrack.forEach { [weak self] card in
                self?.homeActions.trackCardImpression(
                    AnalyticsInfo(
                        type: card.type,
                        url: card.givenURL,
                        index: card.index,
                        recommendationID: card.recommendationID
                    )
                )
            }
        }
    }
}

/// A type that represents a card in its coordinate space
struct GeometryCard: Equatable {
    var card: HomeCardConfiguration
    var bounds: Anchor<CGRect>
}

/// A preference key to track visible items on screen
struct VisibleItemsPreference: PreferenceKey {
    static let defaultValue: [GeometryCard] = []
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}
