import Foundation


extension DateFormatter {
    static let clientAPI: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        return formatter
    }()
}
