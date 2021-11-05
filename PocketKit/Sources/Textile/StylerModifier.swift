public protocol StylerModifier {
    var fontSizeAdjustment: Int { get }
    var fontFamily: FontDescriptor.Family { get }
}

public extension Style {
    func modified(by modifier: StylerModifier) -> Style {
        self.with(family: modifier.fontFamily)
            .adjustingSize(by: modifier.fontSizeAdjustment)
    }
}
