import SwiftUI
import Sync
import Combine

protocol ListOptionsHolder: AnyObject {
    var selectedSortOption: SortOption { get set }
    var publisher: AnyPublisher<Void, Never> { get }
}

class ListOptions: ObservableObject {
    static let saved = ListOptions(holder: SavedListOptions())
    static let archived = ListOptions(holder: ArchiveListOptions())

    private let holder: any ListOptionsHolder
    private var cancellable: AnyCancellable?

    init(holder: any ListOptionsHolder) {
        self.holder = holder
        self.cancellable = holder.publisher.sink {
            self.objectWillChange.send()
        }
    }

    var selectedSortOption: SortOption {
        get {
            holder.selectedSortOption
        }
        set {
            holder.selectedSortOption = newValue
        }
    }
}

class SavedListOptions: ObservableObject, ListOptionsHolder {
    @AppStorage("listSelectedSortForSaved")
    var selectedSortOption: SortOption  = .newest

    private var cancellable: AnyCancellable?
    private let _publisher: PassthroughSubject<Void, Never>
    var publisher: AnyPublisher<Void, Never> {
        _publisher.eraseToAnyPublisher()
    }

    init() {
        _publisher = .init()
        cancellable = objectWillChange.sink { [weak self] in
            self?._publisher.send()
        }
    }
}

class ArchiveListOptions: ObservableObject, ListOptionsHolder {
    @AppStorage("listSelectedSortForArchive")
    var selectedSortOption: SortOption  = .newest

    private var cancellable: AnyCancellable?
    private let _publisher: PassthroughSubject<Void, Never>
    var publisher: AnyPublisher<Void, Never> {
        _publisher.eraseToAnyPublisher()
    }

    init() {
        _publisher = .init()
        cancellable = objectWillChange.sink { [weak self] in
            self?._publisher.send()
        }
    }
}
