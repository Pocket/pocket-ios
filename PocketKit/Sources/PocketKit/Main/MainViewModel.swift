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
    let myList: MyListContainerViewModel
    let account: AccountViewModel

    init(
        myList: MyListContainerViewModel,
        home: HomeViewModel,
        account: AccountViewModel
    ) {
        self.myList = myList
        self.home = home
        self.account = account
    }

    enum Subsection {
        case myList
        case archive
    }

    enum AppSection: CaseIterable, Identifiable, Hashable {
        static var allCases: [MainViewModel.AppSection] {
            return [.home, .myList(nil), .account]
        }

        case home
        case myList(Subsection?)
        case account

        var navigationTitle: String {
            switch self {
            case .home:
                return "Home"
            case .myList:
                return "Saves"
            case .account:
                return "Settings"
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
        myList.clearSharedActivity()
    }

    func clearIsPresentingReaderSettings() {
        home.clearIsPresentingReaderSettings()
        myList.clearIsPresentingReaderSettings()
    }

    func clearPresentedWebReaderURL() {
        home.clearPresentedWebReaderURL()
        myList.clearPresentedWebReaderURL()
    }

    func navigationSidebarCellViewModel(for appSection: AppSection) -> NavigationSidebarCellViewModel {
        let isSelected: Bool = {
            switch (selectedSection, appSection) {
            case (.home, .home), (.myList, .myList), (.account, .account):
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
