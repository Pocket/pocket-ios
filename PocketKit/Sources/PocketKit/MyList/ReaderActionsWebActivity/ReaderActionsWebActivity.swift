import UIKit
import Textile

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
            return L10n.save
        case .report:
            return L10n.report
        case .delete:
            return L10n.delete
        case .favorite:
            return L10n.favorite
        case .unfavorite:
            return L10n.unfavorite
        case .archive:
            return L10n.archive
        case .moveToSaves:
            return L10n.moveToSaves
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
