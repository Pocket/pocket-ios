import UIKit
import Textile

struct NavigationSidebarCellViewModel {
    private let section: MainViewModel.AppSection
    private let isSelected: Bool

    init(section: MainViewModel.AppSection, isSelected: Bool) {
        self.section = section
        self.isSelected = isSelected
    }

    var attributedTitle: NSAttributedString? {
        var style: Style = .navigationSidebarItemTitle
        if isSelected {
            style = style.with(color: .ui.teal2)
        }

        return NSAttributedString(string: section.navigationTitle, style: style)
    }

    var iconImageTintColor: UIColor? {
        if isSelected {
            return UIColor(.ui.teal2)
        } else {
            return nil
        }
    }

    var iconImage: UIImage? {
        let asset: ImageAsset

        switch (section, isSelected) {
        case (.home, true):
            asset = .tabHomeSelected
        case (.home, false):
            asset = .tabHomeDeselected
        case (.myList, true):
            asset = .tabMyListSelected
        case (.myList, false):
            asset = .tabMyListDeselected
        case (.account, true):
            asset = .tabAccountSelected
        case (.account, false):
            asset = .tabAccountDeselected
        }

        return UIImage(asset: asset)
    }
}

private extension Style {
    static let navigationSidebarItemTitle: Style = .header.sansSerif.p2
}
