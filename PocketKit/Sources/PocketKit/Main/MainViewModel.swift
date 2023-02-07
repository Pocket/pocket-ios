import Combine
import Sync
import Foundation
import BackgroundTasks
import UIKit

class MainViewModel: ObservableObject {
    @Published
    var selectedSection: AppSection = .home

    @Published
    var isCollapsed = UIDevice.current.userInterfaceIdiom == .phone

    let home: HomeViewModel
    let saves: SavesContainerViewModel
    let account: AccountViewModel

    init(
        saves: SavesContainerViewModel,
        home: HomeViewModel,
        account: AccountViewModel
    ) {
        self.saves = saves
        self.home = home
        self.account = account
    }

    enum Subsection {
        case saves
        case archive
    }

    enum AppSection: CaseIterable, Identifiable, Hashable {
        static var allCases: [MainViewModel.AppSection] {
            return [.home, .saves(nil), .account]
        }

        case home
        case saves(Subsection?)
        case account

        var navigationTitle: String {
            switch self {
            case .home:
                return "Home".localized()
            case .saves:
                return "Saves".localized()
            case .account:
                return "Settings".localized()
            }
        }

        var id: AppSection {
            return self
        }
    }

    func clearRecommendationToReport() {
        home.clearRecommendationToReport()
    }

    func clearSharedActivity() {
        home.clearSharedActivity()
        saves.clearSharedActivity()
    }

    func clearIsPresentingReaderSettings() {
        home.clearIsPresentingReaderSettings()
        saves.clearIsPresentingReaderSettings()
    }

    func clearPresentedWebReaderURL() {
        home.clearPresentedWebReaderURL()
        saves.clearPresentedWebReaderURL()
    }

    func navigationSidebarCellViewModel(for appSection: AppSection) -> NavigationSidebarCellViewModel {
        let isSelected: Bool = {
            switch (selectedSection, appSection) {
            case (.home, .home), (.saves, .saves), (.account, .account):
                return true
            default:
                return false
            }
        }()

        return NavigationSidebarCellViewModel(
            section: appSection,
            isSelected: isSelected
        )
    }
}
