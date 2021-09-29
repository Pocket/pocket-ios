import Sync

extension Item: Readable {
    func shareActivity(additionalText: String?) -> PocketActivity? {
        PocketItemActivity(item: self, additionalText: additionalText)
    }
}
