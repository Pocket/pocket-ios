// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Messages

public class StickerBrowserController: MSStickerBrowserViewController {
    func stickers() -> [MSSticker] {
        var _userStickers: [MSSticker] = []

        if let pocketSticker = try? MSSticker(item: .PocketLogo) {
            _userStickers.append(pocketSticker)
        }

        return _userStickers
    }

    public override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
      return stickers().count
    }

    public override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
      return stickers()[index]
    }
}
