import Foundation
import SwiftUI

class ListOptions: ObservableObject {
    @AppStorage("listSelectedSort")
    var selectedSort: SortOption = .newest
}
