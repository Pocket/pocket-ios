import PocketGraph

// TODO: To be fleshed out when we work on displaying search results
struct SearchItem {
    private let item: ItemsListItem

    init(item: ItemsListItem) {
        self.item = item
    }

    var id: String? {
        item.id
    }

    var title: String {
        [
            item.title,
            item.bestURL?.absoluteString
        ]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? ""
    }

    var detail: String? {
        guard let tagNames = item.tagNames?.joined(separator: " "), !tagNames.isEmpty else { return nil }
        return "Tags: \(tagNames)"
    }
}
