// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Messages

enum StickerError: Error {
    case fileLoadError(String)
}

extension MSSticker {
  enum PocketSticker: String {
    case BestOf2023Top1Percent,
         BestOf2023Top5Percent,
         PocketLogo
  }

  // https://developer.apple.com/design/human-interface-guidelines/imessage-apps-and-stickers
  convenience init(item: PocketSticker) throws {
    guard let fileURL =  Bundle.module.url(forResource: "\(item.rawValue)-Regular", withExtension: "png", subdirectory: "Stickers") else {
        throw StickerError.fileLoadError("Could not load the file for the sticker \(item.rawValue)")
    }

    try self.init(contentsOfFileURL: fileURL, localizedDescription: "")
  }
}
