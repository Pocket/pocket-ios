import Foundation
import Sync
import Textile
import UIKit


protocol SavedFromClipboardViewModelDelegate: AnyObject {
    func coordinatorDismissBanner()
}

class SavedFromClipboardViewModel: BannerViewModel {
    let prompt = "Add copied URL to your Saves?"
    let clipboardURL: String?
    let buttonText: String? = "Save"
    
    private let source: Source?
    weak var delegate: SavedFromClipboardViewModelDelegate?
    
    init(clipboardURL: String?, source: Source? = nil) {
        self.clipboardURL = clipboardURL
        self.source = source
    }
    
    func action() {
        guard let clipboardURL = clipboardURL, let url =  URL(string: clipboardURL) else { return }
        source?.save(url: url)
        delegate?.coordinatorDismissBanner()
    }
    
    var attributedText: NSAttributedString {
        return NSAttributedString(string: prompt, style: .main)
    }
    
    var attributedDetailText: NSAttributedString {
        return NSAttributedString(string: clipboardURL ?? "", style: .detail)
    }
    
    var attributedButtonText: NSAttributedString {
        return NSAttributedString(string: buttonText ?? "", style: .button)
    }
    
    var backgroundColor: UIColor = UIColor(.ui.teal6)
    var borderColor: UIColor = UIColor(.ui.teal5)
}

private extension Style {
    static let main: Self = .header.sansSerif.p2.with(weight: .semibold).with { paragraph in
        paragraph.with(lineSpacing: 4)
    }
    static let detail: Self = .header.sansSerif.p4.with { paragraph in
        paragraph.with(lineBreakMode: .byTruncatingTail)
    }.with(maxScaleSize: 16)
    static let button: Self = .header.sansSerif.h8.with(color: .ui.white1)
}
