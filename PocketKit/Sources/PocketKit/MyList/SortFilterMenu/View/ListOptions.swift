import SwiftUI
import Sync

class ListOptions: ObservableObject {
    @AppStorage("listSelectedSort")
    var selectedSort: SortOption  = .newest
}
