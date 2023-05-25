// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public struct VIDExtractor {
    public let vid: String?

    public init(_ component: VideoComponent) {
        if let vid = component.vid, !vid.isEmpty {
            self.vid = vid
        } else {
            switch component.type {
            case .youtube:
                vid = Self.extractYouTubeVID(from: component.source)
            default:
                vid = nil
            }
        }
    }

    private static func extractYouTubeVID(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else {
            return nil
        }

        let validDomains = [
            "youtube.com",
            "youtube-nocookie.com",
            "youtu.be"
        ]

        func containsDomain(_ host: String) -> Bool {
            for domain in validDomains {
                if host == domain || host.hasSuffix(".\(domain)") {
                    return true
                }
            }

            return false
        }

        guard containsDomain(host) else {
            return nil
        }

        let pathComponents = (components.path as NSString).pathComponents
        guard pathComponents.count > 1 else {
            return nil
        }

        if let extracted = extractYouTubeVIDFromQuery(components.queryItems) {
            return extracted
        } else if let extracted = extractYouTubeVIDFromPath(pathComponents) {
            return extracted
        } else if pathComponents.count == 2 {
            return pathComponents[1]
        } else {
            return nil
        }
    }

    private static func extractYouTubeVIDFromQuery(_ queryItems: [URLQueryItem]?) -> String? {
        let validQueries = [
            "v",
            "vi"
        ]

        func extractedValue(_ queryItems: [URLQueryItem]) -> String? {
            for query in validQueries {
                if let value = queryItems.first(where: { $0.name == query })?.value {
                    return value
                }
            }

            return nil
        }

        return extractedValue(queryItems ?? []) ?? nil
    }

    private static func extractYouTubeVIDFromPath(_ pathComponents: [String]) -> String? {
        guard pathComponents.count > 2 else {
            return nil
        }

        return pathComponents[2]
    }
}
