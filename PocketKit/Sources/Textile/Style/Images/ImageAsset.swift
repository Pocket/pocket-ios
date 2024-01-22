// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public struct ImageAsset {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

extension ImageAsset {
    public static let accountDeleted = ImageAsset("accountDeleted")
    public static let save = ImageAsset("save")
    public static let saved = ImageAsset("saved")
    public static let alert = ImageAsset("alert")
    public static let overflow = ImageAsset("overflow")
    public static let favorite = ImageAsset("favorite")
    public static let favoriteFilled = ImageAsset("favorite.filled")
    public static let share = ImageAsset("share")
    public static let radioSelected = ImageAsset("radioSelected")
    public static let radioDeselected = ImageAsset("radioDeselected")
    public static let saves = ImageAsset("saves")
    public static let delete = ImageAsset("delete")
    public static let sortFilter = ImageAsset("sort-filter")
    public static let sort = ImageAsset("sort")
    public static let archive = ImageAsset("archive")
    public static let listen = ImageAsset("listen")
    public static let looking = ImageAsset("looking")
    public static let loggedOutCarousel1 = ImageAsset("loggedOutCarousel1")
    public static let loggedOutCarousel2 = ImageAsset("loggedOutCarousel2")
    public static let loggedOutCarousel3 = ImageAsset("loggedOutCarousel3")
    public static let labeledIcon = ImageAsset("labeledIcon")
    public static let logo = ImageAsset("logo")
    public static let circleChecked = ImageAsset("circleChecked")
    public static let error = ImageAsset("error")
    public static let chest = ImageAsset("chest")
    public static let welcomeShelf = ImageAsset("welcomeShelf")
    public static let tabAccountDeselected = ImageAsset("tab.account.deselected")
    public static let tabAccountSelected = ImageAsset("tab.account.selected")
    public static let tabSettingsSelected = ImageAsset("tab.settings.selected")
    public static let tabSettingsDeselected = ImageAsset("tab.settings.deselected")
    public static let tabHomeDeselected = ImageAsset("tab.home.deselected")
    public static let tabHomeSelected = ImageAsset("tab.home.selected")
    public static let tabSavesDeselected = ImageAsset("tab.saves.deselected")
    public static let tabSavesSelected = ImageAsset("tab.saves.selected")
    public static let itemSkeletonActions = ImageAsset("item-skeleton.actions")
    public static let itemSkeletonTags = ImageAsset("item-skeleton.tags")
    public static let itemSkeletonThumbnail = ImageAsset("item-skeleton.thumbnail")
    public static let itemSkeletonTitle = ImageAsset("item-skeleton.title")
    public static let chevronRight = ImageAsset("chevronRight")
    public static let tag = ImageAsset("tag")
    public static let pocketWordmark = ImageAsset("pocket-wordmark")
    public static let close = ImageAsset("close")
    public static let remove = ImageAsset("remove")
    public static let checkMini = ImageAsset("checkMini")
    public static let premiumBorderTop = ImageAsset("premium.border.top")
    public static let premiumBorderBottom = ImageAsset("premium.border.bottom")
    public static let premiumBorderLeft = ImageAsset("premium.border.left")
    public static let premiumBorderRight = ImageAsset("premium.border.right")
    public static let premiumIcon = ImageAsset("premium.icon")
    public static let premiumIconColorful = ImageAsset("premium.icon.colorful")
    public static let magnifyingGlass = ImageAsset("magnifying-glass")
    public static let search = ImageAsset("search")
    public static let searchNoResults = ImageAsset("search.noresults")
    public static let searchRecent = ImageAsset("search.recent")
    public static let diamond = ImageAsset("diamond")
    public static let warning = ImageAsset("warning")
    public static let premiumHoorayLight = ImageAsset("premium.hooray.light")
    public static let premiumHoorayDark = ImageAsset("premium.hooray.dark")
    public static let readerSkeleton = ReaderSkeleton()
    public static let syndicatedIcon = ImageAsset("syndicated-icon")
    public static let highlights = ImageAsset("magicMarker")
}

public struct ReaderSkeleton {
    public let byline = ImageAsset("reader-skeleton.byline")
    public let head = ImageAsset("reader-skeleton.head")
    public let thumbnail = ImageAsset("reader-skeleton.thumbnail")
    public let subhead = ImageAsset("reader-skeleton.subhead")
    public let content = ImageAsset("reader-skeleton.content")
}
