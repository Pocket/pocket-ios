import Sync

extension SavedItem: Readable {
    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(item: self, additionalText: additionalText)
    }
}
