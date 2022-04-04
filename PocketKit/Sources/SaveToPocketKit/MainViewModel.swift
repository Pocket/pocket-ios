import Foundation
import SharedPocketKit
import Sync
import Textile
import Combine


class MainViewModel {
    private let appSession: AppSession
    private let saveService: SaveService
    private let dismissTimer: Timer.TimerPublisher

    private var dismissTimerCancellable: AnyCancellable? = nil

    let style: MainViewStyle
    let attributedText: NSAttributedString
    let attributedDetailText: NSAttributedString?

    init(appSession: AppSession, saveService: SaveService, dismissTimer: Timer.TimerPublisher) {
        self.appSession = appSession
        self.saveService = saveService
        self.dismissTimer = dismissTimer

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
        guard appSession.currentSession != nil else {
            autodismiss(from: context)
            return
        }

        let extensionItems = context?.extensionItems ?? []

        for item in extensionItems {
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

        autodismiss(from: context)
    }

    func finish(context: ExtensionContext?) {
        context?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private func autodismiss(from context: ExtensionContext?) {
        dismissTimerCancellable = dismissTimer.autoconnect().sink { [weak self] _ in
            self?.finish(context: context)
        }
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
