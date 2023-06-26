// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import PKTListen
import SharedPocketKit

extension SavedItem: PKTListenItem {
    public var albumID: String? {
        self.remoteID
    }

    public var localAlbumID: String? {
        self.remoteID
    }

    public var albumTitle: String? {
        self.displayTitle
    }

    public var albumArtist: String? {
        self.displayAuthors
    }

    public var albumStudio: String? {
        self.displayDomain
    }

    public var albumLanguage: String? {
        self.item?.language
    }

    public var estimatedAlbumDuration: TimeInterval {
        if let wordCount = item?.wordCount?.intValue, wordCount > 0 {
            let wordsPerMinute = 155
            return Double(wordCount/wordsPerMinute * 60).rounded()
        }

        if let timeToRead = item?.timeToRead?.intValue, timeToRead > 0 {
            return Double(timeToRead * 60)
        }

        return 0
    }

    public var albumArtRemoteURL: URL? {
        CDNURLBuilder().imageCacheURL(for: self.topImageURL)
    }

    public var canArchiveAlbum: Bool {
        !self.isArchived
    }

    public var hasAlbumArt: Bool {
        self.topImageURL != nil
    }

    public var albumArtIsAvailableOffline: Bool {
        return true
    }

    public var albumJSON: [String: Any]? {
        return nil
    }

    public var givenURL: URL? {
        self.url
    }

    public var localID: String? {
        self.remoteID
    }
}

extension SavedItem: PKTImageResource {
    // TODO: Followup with nicole on this class.
    public var imageIsEphemeral: Bool {
        self.isArchived // TODO: Ask nicole what this does
    }

    public var imageResourceID: String? {
        self.remoteID
    }

    public var imageResourceURL: URL? {
        CDNURLBuilder().imageCacheURL(for: self.topImageURL) ?? fallbackResourceURL
    }

    public var fallbackResourceURL: URL? {
        // fallback if image cache is unavailable
        self.topImageURL
    }

    public var imageResourceRequest: URLRequest? {
        guard let url = self.imageResourceURL else {
            return nil
        }
        return URLRequest(url: url)
    }
}

extension SavedItem: PKTListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        NSString(string: self.remoteID ?? "nil")
    }

    public func isEqual(toDiffableObject object: PKTListDiffable?) -> Bool {
        guard let object else {
            // no object to compare to.
            // TODO: ask nicole if this can happen or a header issue.
            return false
        }
        return self.diffIdentifier().isEqual(object.diffIdentifier())
    }
}
