public struct ImageAsset {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

extension ImageAsset {
    public static let save = ImageAsset("save")
    public static let saved = ImageAsset("saved")
    public static let alert = ImageAsset("alert")
    public static let overflow = ImageAsset("overflow")
    public static let favorite = ImageAsset("favorite")
    public static let favoriteFilled = ImageAsset("favorite.filled")
    public static let share = ImageAsset("share")
    public static let radioSelected = ImageAsset("radioSelected")
    public static let radioDeselected = ImageAsset("radioDeselected")
    public static let myList = ImageAsset("myList")
    public static let sortFilter = ImageAsset("sort-filter")
    public static let sort = ImageAsset("sort")
    public static let archive = ImageAsset("archive")
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
    public static let tabMyListDeselected = ImageAsset("tab.my-list.deselected")
    public static let tabMyListSelected = ImageAsset("tab.my-list.selected")
    public static let itemSkeletonActions = ImageAsset("item-skeleton.actions")
    public static let itemSkeletonTags = ImageAsset("item-skeleton.tags")
    public static let itemSkeletonThumbnail = ImageAsset("item-skeleton.thumbnail")
    public static let itemSkeletonTitle = ImageAsset("item-skeleton.title")
    public static let chevronRight = ImageAsset("chevronRight")
    public static let tag = ImageAsset("tag")
    public static let pocketWordmark = ImageAsset("pocket-wordmark")

    public static let readerSkeleton = ReaderSkeleton()
}

public struct ReaderSkeleton {
    public let byline = ImageAsset("reader-skeleton.byline")
    public let head = ImageAsset("reader-skeleton.head")
    public let thumbnail = ImageAsset("reader-skeleton.thumbnail")
    public let subhead = ImageAsset("reader-skeleton.subhead")
    public let content = ImageAsset("reader-skeleton.content")
}
