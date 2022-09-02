import Foundation
import Kingfisher
@testable import PocketKit

class MockImageCache: ImageCacheProtocol {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

extension MockImageCache {
    private static let removeImage = "removeImage"

    typealias RemoveImageImpl = (
        String,
        String,
        Bool,
        Bool,
        CallbackQueue,
        (() -> Void)?
    ) -> Void

    struct RemoveImageCall {
        let key: String
        let processorIdentifier: String
        let fromMemory: Bool
        let fromDisk: Bool
        let callbackQueue: CallbackQueue
        let completionHandler: (() -> Void)?
    }

    func stubRemoveImage(_ impl: @escaping RemoveImageImpl) {
        implementations[Self.removeImage] = impl
    }

    func removeImageCall(at index: Int) -> RemoveImageCall? {
        guard let calls = calls[Self.removeImage], index < calls.count else {
            return nil
        }

        return calls[index] as? RemoveImageCall
    }

    func removeImage(
        forKey key: String,
        processorIdentifier identifier: String,
        fromMemory: Bool,
        fromDisk: Bool,
        callbackQueue: CallbackQueue,
        completionHandler: (() -> Void)?
    ) {
        guard let impl = implementations[Self.removeImage] as? RemoveImageImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.removeImage] = (calls[Self.removeImage] ?? []) + [
            RemoveImageCall(
                key: key,
                processorIdentifier: identifier,
                fromMemory: fromMemory,
                fromDisk: fromDisk,
                callbackQueue: callbackQueue,
                completionHandler: completionHandler
            )
        ]

        impl(key, identifier, fromMemory, fromDisk, callbackQueue, completionHandler)
    }
}

class MockImageRetriever: ImageRetriever {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    private let _imageCache: MockImageCache
    var imageCache: ImageCacheProtocol {
        _imageCache
    }

    init(imageCache: MockImageCache) {
        _imageCache = imageCache
    }
}

extension MockImageRetriever {
    private static let retrieveImage = "retrieveImage"

    typealias RetrieveImageImpl = (
        Resource,
        KingfisherOptionsInfo?,
        DownloadProgressBlock?,
        DownloadTaskUpdatedBlock?,
        ((Result<RetrieveImageResult, KingfisherError>) -> Void)?
    ) -> DownloadTask?

    struct RetrieveImageCall {
        let resource: Resource
    }

    func stubRetrieveImage(_ impl: @escaping RetrieveImageImpl) {
        implementations[Self.retrieveImage] = impl
    }

    func retrieveImageCall(at index: Int) -> RetrieveImageCall? {
        guard let calls = calls[Self.retrieveImage], calls.count > index else {
            return nil
        }

        return calls[index] as? RetrieveImageCall
    }

    func retrieveImage(
        with resource: Resource,
        options: KingfisherOptionsInfo?,
        progressBlock: DownloadProgressBlock?,
        downloadTaskUpdated: DownloadTaskUpdatedBlock?,
        completionHandler: ((Result<RetrieveImageResult, KingfisherError>) -> Void)?
    ) -> DownloadTask? {
        guard let impl = implementations[Self.retrieveImage] as? RetrieveImageImpl else {
            fatalError("\(Self.self).\(#function) is not stubbed")
        }

        calls[Self.retrieveImage] = (calls[Self.retrieveImage] ?? []) + [RetrieveImageCall(resource: resource)]
        return impl(resource, options, progressBlock, downloadTaskUpdated, completionHandler)
    }
}
