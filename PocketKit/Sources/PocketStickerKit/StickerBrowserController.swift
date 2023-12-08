// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Messages
import Analytics

extension MSMessagesAppPresentationContext {
    func toAnalytics() -> Events.Stickers.MessagesContext {
        switch self {
        case .media:
            return .media
        case .messages:
            return .messages
        @unknown default:
            return .unknown
        }
    }
}

class StickerBrowserController: MSStickerBrowserViewController {
    let braze: StickerBraze
    let tracker: Tracker
    let context: MSMessagesAppPresentationContext

    let _stickers: [MSSticker]? = nil

    public init(braze: StickerBraze, tracker: Tracker, context: MSMessagesAppPresentationContext) {
        self.braze = braze
        self.tracker = tracker
        self.context = context
        super.init(stickerSize: .regular)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tracker.track(event: Events.Stickers.StickersView(context: context.toAnalytics()))
    }

    func stickers() -> [MSSticker] {
        if let stickers = _stickers {
            return stickers
        }

        var _userStickers: [MSSticker] = []

        if let pocketSticker = try? MSSticker(item: .PocketLogo) {
            _userStickers.append(pocketSticker)
        }

        if braze.isFeatureFlagEnabled(flag: .bestOf20231PercentSticker), let bestOf20231PercentSticker = try? MSSticker(item: .BestOf2023Top1Percent) {
            _userStickers.append(bestOf20231PercentSticker)
            _ = braze.logFeatureFlagImpression(flag: .bestOf20231PercentSticker)
        }

        if braze.isFeatureFlagEnabled(flag: .bestOf20235PercentSticker), let bestOf20235PercentSticker = try? MSSticker(item: .BestOf2023Top5Percent) {
            _userStickers.append(bestOf20235PercentSticker)
            _ = braze.logFeatureFlagImpression(flag: .bestOf20235PercentSticker)
        }

        return _userStickers
    }

    override func numberOfStickers(in stickerBrowserView: MSStickerBrowserView) -> Int {
      return stickers().count
    }

    override func stickerBrowserView(_ stickerBrowserView: MSStickerBrowserView, stickerAt index: Int) -> MSSticker {
      return stickers()[index]
    }
}
