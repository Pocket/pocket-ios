// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

enum PocketAppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    case pride = "AppIcon-Pride"

    var id: String {
        rawValue
    }

    var iconName: String? {
        switch self {
        case .primary:
            return nil
        default:
            return rawValue
        }
    }

    var description: String {
        switch self {
        case .primary:
            return "Default"
        case .pride:
            return "Pride"
        }
    }

    var previewName: String {
        rawValue + "-Preview"
    }
}
