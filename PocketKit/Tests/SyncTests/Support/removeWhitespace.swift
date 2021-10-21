import Foundation


func removeWhitespace(_ data: Data?) -> String? {
    return data.flatMap {
        String(data: $0, encoding: .utf8)?
            .replacingOccurrences(
                of: #"[\n\s]"#,
                with: "",
                options: .regularExpression
            )
    }
}
