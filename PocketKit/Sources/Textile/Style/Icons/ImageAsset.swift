public struct ImageAsset {
    let name: String

    init(_ name: String) {
        self.name = name
    }
}

extension ImageAsset {
    public static let save = ImageAsset("save")
    public static let horizontalOverflow = ImageAsset("horizontalOverflow")
    public static let verticalOverflow = ImageAsset("verticalOverflow")
}
