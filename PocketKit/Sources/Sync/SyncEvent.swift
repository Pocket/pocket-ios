public enum SyncEvent {
    case error(Error)
    case loadedArchivePage
    case savedItemCreated
    case savedItemsUpdated(Set<SavedItem>)
}
