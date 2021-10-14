public struct ImageAsset {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

extension ImageAsset {
    public static let save = ImageAsset("save")
    public static let saved = ImageAsset("saved")
    public static let horizontalOverflow = ImageAsset("horizontalOverflow")
    public static let verticalOverflow = ImageAsset("verticalOverflow")
    public static let alert = ImageAsset("alert")
    public static let radioSelected = ImageAsset("radioSelected")
    public static let radioDeselected = ImageAsset("radioDeselected")
}
