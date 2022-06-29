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

    enum AppSection: CaseIterable, Identifiable {
        case home
        case myList
        case account

        var navigationTitle: String {
            switch self {
            case .home:
                return "Home"
            case .myList:
                return "My List"
            case .account:
                return "Account"
            }
        }

        var id: AppSection {
            return self
        }
    }
}
