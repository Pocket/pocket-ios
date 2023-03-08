extension Source {
    public func refresh(maxItems: Int = 400) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            refreshSaves(maxItems: maxItems) {
                continuation.resume(returning: ())
            }
        }
    }
}
