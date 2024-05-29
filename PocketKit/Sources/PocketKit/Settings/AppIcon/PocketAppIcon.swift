// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Localization

enum PocketAppIcon: String, CaseIterable, Identifiable {
    case primary = "AppIcon"
    // TODO: pride currently disable while we wait for the official icon
    // case pride = "AppIcon-Pride"
    case monochrome = "AppIcon-Monochrome"
    case classic = "AppIcon-Classic"
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
            return Localization.Settings.AppIcon.IconName.default
        case .monochrome:
            return Localization.Settings.AppIcon.IconName.monochrome
        case .classic:
            return Localization.Settings.AppIcon.IconName.classic
        case .pride:
            return Localization.Settings.AppIcon.IconName.pride
        }
    }

    var previewName: String {
        rawValue + "-Preview"
    }

    static var selectableIcons: [PocketAppIcon] {
        Self.allCases.filter { $0 != .primary }
    }

    static let currentDefaultName = "Classic"
}
