import Foundation
import SwiftUI
import Textile

class EmptyStateViewModel: ObservableObject {

    @Published
    var emptyState: ItemsEmptyState

    init(emptyState: ItemsEmptyState) {
        self.emptyState = emptyState
    }
    
    var imageAsset: ImageAsset {
        switch emptyState {
        case .myList:
            return .welcomeShelf
        case .archive:
            return .chest
        case .favorites:
            return .chest
        }
    }
    
    var icon: ImageAsset? {
        switch emptyState {
        case .myList:
            return nil
        case .archive:
            return .archive
        case .favorites:
            return .favorite
        }
    }
    
    var headline: String {
        switch emptyState {
        case .myList:
            return "Start building your Pocket list"
        case .archive:
            return "Keep your list fresh and clean"
        case .favorites:
            return "Find your favorites here"
        }
    }
    
    var detailText: String {
        switch emptyState {
        case .myList:
            return ""
        case .archive:
            return "Archive the saves you're finished with\n using the archive icon."
        case .favorites:
            return "Hit the star icon to favorite an article and find it faster."
        }
    }
    
    var buttonText: String {
        switch emptyState {
        case .myList:
            return "How to save"
        case .archive:
            return "How to archive"
        case .favorites:
            return ""
        }
    }
    
    var hasButton: Bool {
        switch emptyState {
        case .myList, .archive:
            return true
        case .favorites:
            return false
        }
    }
    
    var hasSubtitle: Bool {
        switch emptyState {
        case .myList:
            return false
        case .archive, .favorites:
            return true
        }
    }
    
    var webURL: String {
        switch emptyState {
        case .myList:
            return "https://getpocket.com/saving-in-ios"
        case .archive:
            return "https://getpocket.com/what-is-the-archive-ios"
        case .favorites:
            return ""
        }
    }
}
