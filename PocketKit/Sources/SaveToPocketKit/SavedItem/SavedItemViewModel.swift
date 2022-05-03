import Foundation
import SharedPocketKit
import Sync
import Combine


class SavedItemViewModel {
    private let appSession: AppSession
    private let saveService: SaveService
    private let dismissTimer: Timer.TimerPublisher

    private var dismissTimerCancellable: AnyCancellable? = nil

    @Published
    var infoViewModel: InfoView.Model = .empty

    let dismissAttributedText = NSAttributedString(string: "Tap to Dismiss", style: .dismiss)

    init(appSession: AppSession, saveService: SaveService, dismissTimer: Timer.TimerPublisher) {
        self.appSession = appSession
        self.saveService = saveService
        self.dismissTimer = dismissTimer
    }

    func save(from context: ExtensionContext?) async {
        guard appSession.currentSession != nil else {
            autodismiss(from: context)
            return
        }

        let extensionItems = context?.extensionItems ?? []

        for item in extensionItems {
            guard let url = try? await url(from: item) else {
                infoViewModel = .error
                break
            }

            switch saveService.save(url: url) {
            case .existingItem:
                infoViewModel = .existingItem
            case .newItem:
                infoViewModel = .newItem
            }

            break
        }

        autodismiss(from: context)
    }

    func finish(context: ExtensionContext?, completionHandler: ((Bool) -> Void)? = nil) {
        context?.completeRequest(returningItems: nil, completionHandler: completionHandler)
    }
}

extension SavedItemViewModel {
    private func autodismiss(from context: ExtensionContext?) {
        dismissTimerCancellable = dismissTimer.autoconnect().first().sink { [weak self] _ in
            self?.finish(context: context)
        }
    }

    private func url(from item: ExtensionItem) async throws -> URL? {
        guard let providers = item.itemProviders else {
            return nil
        }

        for provider in providers {
            let plainTextUTI = "public.plain-text"
            let urlUTI = "public.url"

            if provider.hasItemConformingToTypeIdentifier(plainTextUTI) {
                guard let string = try? await provider.loadItem(forTypeIdentifier: plainTextUTI, options: nil) as? String,
                      let url = URL(string: string) else {
                    continue
                }

                return url
            } else if provider.hasItemConformingToTypeIdentifier(urlUTI) {
                guard let url = try? await provider.loadItem(forTypeIdentifier: urlUTI, options: nil) as? URL else {
                    continue
                }

                return url
            } else {
                continue
            }
        }

        return nil
    }
}

private extension InfoView.Model {
    static let empty = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(string: ""),
        attributedDetailText: NSAttributedString(string: "")
    )

    static let newItem = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(
            string: "Saved to Pocket",
            style: .mainText
        ),
        attributedDetailText: nil
    )

    static let existingItem = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(
            string: "Saved to Pocket",
            style: .mainText
        ),
        attributedDetailText: NSAttributedString(
            string: "You've already saved this before. We'll move it to the top of your list.",
            style: .detailText
        )
    )

    static let error = InfoView.Model(
        style: .error,
        attributedText: NSAttributedString(
            string: "Pocket couldn't save this link",
            style: .mainTextError
        ),
        attributedDetailText: nil
    )
}
