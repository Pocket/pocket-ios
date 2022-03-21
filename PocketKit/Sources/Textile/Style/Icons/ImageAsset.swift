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
    public static let archive = ImageAsset("archive")
    public static let looking = ImageAsset("looking")
    public static let loggedOutCarousel1 = ImageAsset("loggedOutCarousel1")
    public static let loggedOutCarousel2 = ImageAsset("loggedOutCarousel2")
    public static let loggedOutCarousel3 = ImageAsset("loggedOutCarousel3")
    public static let labeledIcon = ImageAsset("labeledIcon")
    public static let logo = ImageAsset("logo")
    public static let circleChecked = ImageAsset("circleChecked")
}
