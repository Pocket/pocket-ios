// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct ReportEvent: Context {
    public static let schema = "iglu:com.pocket/report/jsonschema/1-0-0"
    
    let reason: Reason
    let comment: String?
    
    public init(reason: Reason, comment: String?) {
        self.reason = reason
        self.comment = comment
    }
}

extension ReportEvent {
    public enum Reason: String, CaseIterable, Encodable {
        case brokenMeta = "broken_meta"
        case wrongCategory = "wrong_category"
        case sexuallyExplicit = "sexually_explicit"
        case offensive
        case misinformation
        case other
    }
}
