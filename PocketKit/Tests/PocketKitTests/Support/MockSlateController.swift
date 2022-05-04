import Sync


class MockSlateController: SlateController {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    var delegate: SlateControllerDelegate?

    var slate: Slate?
}

extension MockSlateController {
    static let performFetch = "performFetch"
    typealias PerformFetchImpl = () -> Void
    struct PerformFetchCall { }

    func stubPerformFetch(impl: @escaping PerformFetchImpl) {
        implementations[Self.performFetch] = impl
    }

    func performFetch() throws {
        guard let impl = implementations[Self.performFetch] as? PerformFetchImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.performFetch] = (calls[Self.performFetch] ?? []) + [PerformFetchCall()]

        impl()
    }

    func performFetchCall(at index: Int) -> PerformFetchCall? {
        guard let calls = calls[Self.performFetch], calls.count > index else {
            return nil
        }

        return calls[index] as? PerformFetchCall
    }
}

