// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum CleanupError: Error {
    case fileNotFound
}

/// Service that cleans up legacy data
public class LegacyCleanupService {
    public func cleanUp() {
        cleanupLegacyUserDefaults()
        deleteSqliteDataBase()
        deleteImageCache()
        deleteLogFiles()
    }

    public init() { }

    /// Remove legacy `UserDefaults` suite
    private func cleanupLegacyUserDefaults() {
        guard let legacyDefaults = UserDefaults(suiteName: Legacy.groupID) else {
            // Legacy dictionary does not exist, no cleanup or migration possible
            return
        }
        legacyDefaults.removePersistentDomain(forName: Legacy.groupID)
    }

    /// Delete legacy log files
    private func deleteLogFiles() {
        deleteContent(at: Legacy.logFolder)
    }

    /// Delete the legacy sqlite database
    private func deleteSqliteDataBase() {
        deleteContent(at: Legacy.storeName)
    }

    /// Delete legacy image cache
    private func deleteImageCache() {
        deleteContent(at: Legacy.imageCacheName)
    }

    /// Delete the audio cache
    private func deleteAudioCache() {
        deleteContent(at: Legacy.audioCacheName)
    }

    /// Remove a file or directory at the specified subpath, inside the shared app group
    /// - Parameter subPath: the file/directory to remove
    private func deleteContent(at subPath: String) {
        do {
            let url = try pathExists(at: Legacy.storeName)
            try FileManager.default.removeItem(at: url)
        } catch {
            // TODO: resolve circular dependency error with Sync to use Log
            print(error)
        }
    }

    /// Check that the specfied path exists in the shared app group
    /// - Parameter subpath: the subpath to check
    /// - Returns: the url at the subpath, if it exists. Otherwise throws an error
    private func pathExists(at subpath: String) throws -> URL {
        guard let url = FileManager
            .default
            .containerURL(forSecurityApplicationGroupIdentifier: Legacy.groupID)?
            .appendingPathExtension(subpath),
              FileManager.default.fileExists(atPath: url.absoluteString) else {
            throw CleanupError.fileNotFound
        }
        return url
    }
}

// MARK: Constants
private extension LegacyCleanupService {
    enum Legacy {
        static let groupID = "group.com.ideashower.ReadItLaterPro"
        static let storeName = "readItLater3.sqlite"
        static let imageCacheName = "images.yap"
        static let audioCacheName = "listen.yap"
        static let logFolder = "PocketMobile"
    }
}
