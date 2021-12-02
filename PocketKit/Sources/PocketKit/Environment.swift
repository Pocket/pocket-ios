// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync


private struct SourceKey: EnvironmentKey {
    static var defaultValue = Services.shared.source
}

private struct CharacterDirectionKey: EnvironmentKey {
    static var defaultValue: LayoutDirection = .leftToRight
}

extension EnvironmentValues {
    var source: Source {
        get { self[SourceKey.self] }
        set { self[SourceKey.self] = newValue }
    }
    
    var characterDirection: LayoutDirection {
        get { self[CharacterDirectionKey.self] }
        set { self[CharacterDirectionKey.self] = newValue }
    }
}
