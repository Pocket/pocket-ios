// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftData
import SwiftUI
import Sync

struct HomeView: View {
    @Query(sort: \Slate.sortIndex, order: .forward)
    var slates: [Slate]
    var body: some View {
        ScrollView {
            VStack {
                ForEach(slates) { slate in
                    HomeSlateView(
                        remoteID: slate.remoteID,
                        slateTitle: slate.name!,
                        recommendations: slate.recommendations!.sorted {
                            $0.sortIndex! < $1.sortIndex!
                        }
                    )
                }
            }
        }
    }
}
