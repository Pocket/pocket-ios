import Combine
import Sync


class ItemSelection: ObservableObject {
    @Published
    var selectedItem: Item?
}
