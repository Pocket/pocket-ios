import Foundation
import Sync
import Textile


private extension Style {
    static let sectionHeader: Style = .header.sansSerif.h8
}

struct SlateHeaderPresenter {
    private let slate: UnmanagedSlate

    init(slate: UnmanagedSlate) {
        self.slate = slate
    }

    var attributedHeaderText: NSAttributedString {
        NSAttributedString(string: slate.name ?? "", style: .sectionHeader)
    }
}
