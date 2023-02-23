import Textile

extension Style {
    func with(settings: ReaderSettings) -> Style {
        self.with(family: settings.fontFamily).modified(by: settings)
    }
}
