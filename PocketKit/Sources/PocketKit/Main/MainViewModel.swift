import Combine
import Sync
import Foundation
import BackgroundTasks


class MainViewModel: ObservableObject {
    @Published
    var selectedSection: AppSection = .home
    
    @Published
    var selectedRecommendationToReport: Slate.Recommendation?
    
    @Published
    var selectedMyListReadableViewModel: ReadableViewModel?
    
    @Published
    var selectedHomeReadableViewModel: ReadableViewModel?

    @Published
    var selectedSlateID: String?

    @Published
    var readerSettings = ReaderSettings()

    @Published
    var isCollapsed = false

    @Published
    var isPresentingReaderSettings = false

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var sharedActivity: PocketActivity?
    
    @Published
    var presentedAlert: PocketAlert?

    let settings: SettingsViewModel

    var refreshTasks: AnyPublisher<BGTask, Never> {
        refreshCoordinator.tasksPublisher
    }

    private let refreshCoordinator: RefreshCoordinator

    init(
        refreshCoordinator: RefreshCoordinator,
        settings: SettingsViewModel
    ) {
        self.refreshCoordinator = refreshCoordinator
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
