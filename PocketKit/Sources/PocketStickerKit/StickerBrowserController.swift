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
    var context: MSMessagesAppPresentationContext?

    let _stickers: [MSSticker]? = nil

    public init(braze: StickerBraze, tracker: Tracker) {
        self.braze = braze
        self.tracker = tracker
        super.init(stickerSize: .regular)
        // This wont respond to interface changes, but will at least make the stickers the right colors on launch
        view.backgroundColor = .systemBackground
        stickerBrowserView.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setPresentationContext(context: MSMessagesAppPresentationContext) {
        self.context = context
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tracker.track(event: Events.Stickers.StickersView(context: context?.toAnalytics()))
    }

    func stickers() -> [MSSticker] {
        if let stickers = _stickers {
            return stickers
        }

        var _userStickers: [MSSticker] = []

        if let pocketSticker = try? MSSticker(item: .PocketLogo) {
            _userStickers.append(pocketSticker)
        }

        if let savedHandsSticker = try? MSSticker(item: .SavedHands) {
            _userStickers.append(savedHandsSticker)
        }

        if let savedSticker = try? MSSticker(item: .Saved) {
            _userStickers.append(savedSticker)
        }

        if let readItLater1Sticker = try? MSSticker(item: .ReadItLater1) {
            _userStickers.append(readItLater1Sticker)
        }

        if let readItLater2Sticker = try? MSSticker(item: .ReadItLater2) {
            _userStickers.append(readItLater2Sticker)
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
