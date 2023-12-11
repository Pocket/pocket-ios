// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedWithYou

protocol SWHighlightCenterProtocol {
    var highlights: [SWHighlight] { get }

    func highlight(for URL: URL) async throws -> SWHighlight

    func getHighlightFor(_ URL: URL, completionHandler: @escaping (SWHighlight?, Error?) -> Void)

    var delegate: SWHighlightCenterDelegate? { get set }
}

// MARK: - SWHighlightCenter Extensions
extension SWHighlightCenter: SWHighlightCenterProtocol { }
