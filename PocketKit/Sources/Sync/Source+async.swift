extension Source {
    public func refresh() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            refreshSaves {
                continuation.resume(returning: ())
            }
        }
    }
}
