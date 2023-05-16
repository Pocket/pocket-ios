import SharedWithYou

protocol SWHighlightCenterProtocol {
    var highlights: [SWHighlight] { get }

    func highlight(for URL: URL) async throws -> SWHighlight

    func getHighlightFor(_ URL: URL, completionHandler: @escaping (SWHighlight?, Error?) -> Void)

    var delegate: SWHighlightCenterDelegate? { get set }
}

// MARK: - SWHighlightCenter Extensions
extension SWHighlightCenter: SWHighlightCenterProtocol { }
