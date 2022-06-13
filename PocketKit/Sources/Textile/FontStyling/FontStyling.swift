public protocol FontStyling {
    var h1: Style { get }
    var h2: Style { get }
    var h3: Style { get }
    var h4: Style { get }
    var h5: Style { get }
    var h6: Style { get }
    var body: Style { get }
    var monospace: Style { get }

    func bolding(style: Style) -> Style

    func with(body: Style) -> FontStyling
}
