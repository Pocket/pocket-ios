// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

enum PocketAppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    // TODO: pride currently disable while we wait for the official icon
    // case pride = "AppIcon-Pride"
    case monochrome = "AppIcon-Monochrome"

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
        case .monochrome:
            return "Monochrome"
        }
    }

    var previewName: String {
        rawValue + "-Preview"
    }
}