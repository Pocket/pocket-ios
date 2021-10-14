import Analytics


struct Report: SnowplowContext {
    static let schema = "iglu:com.pocket/report/jsonschema/1-0-0"
    
    let reason: Reason
    let comment: String?
}

extension Report {
    enum Reason: String, CaseIterable, Encodable {
        case brokenMeta = "broken_meta"
        case wrongCategory = "wrong_category"
        case sexuallyExplicit = "sexually_explicit"
        case offensive
        case misinformation
        case other
    }
}
