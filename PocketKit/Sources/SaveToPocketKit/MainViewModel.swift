import Foundation
import SharedPocketKit
import Textile


class MainViewModel {
    private let appSession: AppSession
    private let saveService: SaveService

    let style: MainViewStyle
    let attributedText: NSAttributedString
    let attributedDetailText: NSAttributedString?

    init(appSession: AppSession, saveService: SaveService) {
        self.appSession = appSession
        self.saveService = saveService

        if appSession.currentSession != nil {
            style = .default
            attributedText = NSAttributedString(string: "Saved to Pocket", style: .mainText)
            attributedDetailText = nil
        } else {
            style = .error
            attributedText = NSAttributedString(string: "Log in to Pocket to save", style: .mainTextError)
            attributedDetailText = NSAttributedString(string: "Pocket couldn't save the link. Log in to the Pocket app and try saving again.", style: .detailText)
        }
    }

    func save(from context: ExtensionContext?) async {
        guard let context = context, !context.extensionItems.isEmpty else {
            return
        }

        for item in context.extensionItems {
            let urlUTI = "public.url"
            guard let url = try? await item.itemProviders?
                .first(where: { $0.hasItemConformingToTypeIdentifier(urlUTI) })?
                .loadItem(forTypeIdentifier: urlUTI, options: nil) as? URL else {
                // TODO: Throw an error?
                break
            }

            saveService.save(url: url)
            break
        }

        return
    }
}

private extension Style {
    static func coloredMainText(color: ColorAsset) -> Style {
        .header.sansSerif.h2.with(color: color).with { $0.with(lineSpacing: 4) }
    }
    static let mainText: Self = coloredMainText(color: .ui.teal2)
    static let mainTextError: Self = coloredMainText(color: .ui.coral2)

    static let detailText: Self = .header.sansSerif.p2.with { $0.with(lineHeight: .explicit(28)).with(alignment: .center) }
}
