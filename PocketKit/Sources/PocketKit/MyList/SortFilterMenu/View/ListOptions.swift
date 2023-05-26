// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Combine

protocol ListOptionsHolder: AnyObject {
    var selectedSortOption: SortOption { get set }
    var publisher: AnyPublisher<Void, Never> { get }
}

class ListOptions: ObservableObject {
    static func saved(userDefaults: UserDefaults) -> ListOptions {
        return ListOptions(holder: SavedListOptions(userDefaults: userDefaults))
    }

    static func archived(userDefaults: UserDefaults) -> ListOptions {
        return ListOptions(holder: ArchiveListOptions(userDefaults: userDefaults))
    }

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
    @AppStorage var selectedSortOption: SortOption

    private var cancellable: AnyCancellable?
    private let _publisher: PassthroughSubject<Void, Never>
    var publisher: AnyPublisher<Void, Never> {
        _publisher.eraseToAnyPublisher()
    }

    init(userDefaults: UserDefaults) {
        _selectedSortOption = AppStorage(wrappedValue: SortOption.newest, UserDefaults.Key.listSelectedSortForSaved, store: userDefaults)

        _publisher = .init()
        cancellable = objectWillChange.sink { [weak self] in
            self?._publisher.send()
        }
    }
}

class ArchiveListOptions: ObservableObject, ListOptionsHolder {
    @AppStorage var selectedSortOption: SortOption

    private var cancellable: AnyCancellable?
    private let _publisher: PassthroughSubject<Void, Never>
    var publisher: AnyPublisher<Void, Never> {
        _publisher.eraseToAnyPublisher()
    }

    init(userDefaults: UserDefaults) {
        _selectedSortOption = AppStorage(wrappedValue: SortOption.newest, UserDefaults.Key.listSelectedSortForArchive, store: userDefaults)

        _publisher = .init()
        cancellable = objectWillChange.sink { [weak self] in
            self?._publisher.send()
        }
    }
}
