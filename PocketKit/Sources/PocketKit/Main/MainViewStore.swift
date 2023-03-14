//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/14/23.
//

import Foundation

protocol MainViewStore {
    var mainSelection: MainViewModel.AppSection { get set }
    var mainSelectionPublisher: Published<MainViewModel.AppSection>.Publisher { get }
}
