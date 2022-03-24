import Foundation


class MainViewModel {
    private let saveService: SaveService

    init(saveService: SaveService) {
        self.saveService = saveService
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

            await saveService.save(url: url)
            break
        }

        return
    }
}
