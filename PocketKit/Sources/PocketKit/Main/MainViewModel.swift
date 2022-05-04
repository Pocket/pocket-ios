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
    let settings: SettingsViewModel

    init(
        myList: MyListContainerViewModel,
        home: HomeViewModel,
        settings: SettingsViewModel
    ) {
        self.myList = myList
        self.home = home
        self.settings = settings
    }

    enum AppSection: CaseIterable, Identifiable {
        case home
        case myList
        case settings

        var navigationTitle: String {
            switch self {
            case .home:
                return "Home"
            case .myList:
                return "My List"
            case .settings:
                return "Settings"
            }
        }

        var id: AppSection {
            return self
        }
    }
}
