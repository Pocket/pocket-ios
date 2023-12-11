// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Textile
import Localization

enum WebActivityTitle: String {
    case save = "Save"
    case report = "Report"
    case delete = "Delete"
    case archive = "Archive"
    case favorite = "Favorite"
    case unfavorite = "Unfavorite"
    case moveToSaves = "Move to saves"

    var imageAsset: ImageAsset {
        switch self {
        case .save:
            return .save
        case .report:
            return .alert
        case .delete:
            return .delete
        case .favorite:
            return .favorite
        case .unfavorite:
            return .favoriteFilled
        case .archive:
            return .archive
        case .moveToSaves:
            return .save
        }
    }

    var localized: String {
        switch self {
        case .save:
            return Localization.Reader.Activity.save
        case .report:
            return Localization.Reader.Activity.report
        case .delete:
            return Localization.Reader.Activity.delete
        case .favorite:
            return Localization.Reader.Activity.favorite
        case .unfavorite:
            return Localization.Reader.Activity.unfavorite
        case .archive:
            return Localization.Reader.Activity.archive
        case .moveToSaves:
            return Localization.Reader.Activity.moveToSaves
        }
    }
}

class ReaderActionsWebActivity: UIActivity {
    override var activityTitle: String? {
        return title
    }

    override var activityImage: UIImage? {
        return UIImage(asset: iconAsset)
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    private let title: String
    private let iconAsset: ImageAsset

    let action: () -> Void

    init(title: WebActivityTitle, action: @escaping () -> Void) {
        self.title = title.localized
        self.iconAsset = title.imageAsset
        self.action = action

        super.init()
    }

    override func perform() {
        action()
    }
}
