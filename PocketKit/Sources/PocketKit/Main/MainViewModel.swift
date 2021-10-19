import Combine
import Sync
import Foundation
import BackgroundTasks


class MainViewModel: ObservableObject {
    @Published
    var selectedSection: AppSection = .home

    @Published
    var selectedItem: SavedItem?

    @Published
    var selectedRecommendation: Slate.Recommendation?
    
    @Published
    var selectedRecommendationToReport: Slate.Recommendation?

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

    var refreshTasks: AnyPublisher<BGTask, Never> {
        refreshCoordinator.tasksPublisher
    }

    private let refreshCoordinator: RefreshCoordinator

    init(refreshCoordinator: RefreshCoordinator) {
        self.refreshCoordinator = refreshCoordinator
    }

    enum AppSection: CaseIterable, Identifiable {
        case home
        case myList

        var navigationTitle: String {
            switch self {
            case .home:
                return "Home"
            case .myList:
                return "My List"
            }
        }

        var id: AppSection {
            return self
        }
    }
}
