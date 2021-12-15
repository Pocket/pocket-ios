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
}
