//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/14/23.
//

import Foundation

final class PocketMainViewStore: MainViewStore, ObservableObject {
    @Published var mainSelection: MainViewModel.AppSection
    var mainSelectionPublisher: Published<MainViewModel.AppSection>.Publisher { $mainSelection }

    convenience init() {
        self.init(mainSelection: .home)
    }

    init(mainSelection: MainViewModel.AppSection) {
        self.mainSelection = mainSelection
    }
}
