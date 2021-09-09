import Combine
import Sync
import Foundation


class MainViewModel: ObservableObject {
    @Published
    var selectedSection: AppSection = .myList

    @Published
    var selectedItem: Item?

    @Published
    var readerSettings = ReaderSettings()

    @Published
    var isCollapsed = false

    @Published
    var isPresentingReaderSettings = false

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var sharedActivityItems: [Any]?

    enum AppSection: CaseIterable, Identifiable {
        case discover
        case myList

        var navigationTitle: String {
            switch self {
            case .discover:
                return "Discover"
            case .myList:
                return "My List"
            }
        }

        var id: AppSection {
            return self
        }
    }
}
