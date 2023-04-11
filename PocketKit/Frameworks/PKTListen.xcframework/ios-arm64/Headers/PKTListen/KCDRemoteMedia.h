//
//  KCDRemoteMedia.h
//
//  Created by Nik on 4/8/15.
//
//

/**
 KCDRemoteMedia is an asynchronous loading facade for loading remote files.
 Its interface is deliberately concise: you can obtain a new instance from one
 of the factory methods; you load the data via
 
 -loadDataWithOptions:progress:completion.
 
 If the file is cached locally on disk, the completion handler will be triggered
 immediately; otherwise, the resource will be loaded using the provied NSURLRequest
 and the completion handler called when loading is complete.
 
 Under the hood, KCDRemoteMedia manages a tiered stack of operations wrapping
 NSURLSessionDownloadTasks. The stack is structured such that each new 'load'
 message moves the underlying request to the top of its tier, with each tier
 being defined by the priority values passed in as options.
 
 KCDRemoteMedia makes two guarantees:
 
 1.  There will never be more than one active download request for a given
 identifier, no matter how many 'load' messages it received.
 
 2.  Any consumer of this API will be notified when loading completes,
 via its completion handler, even if that consumer registered interest
 after the download operation had already begun.
 
 The primary intent of this class is to provide a simple interface to register
 varying degrees of interest in the retrieval of remote resources, without having
 to worry about uneccessary duplication of effort, over overwhelming the system
 with download tasks.
 
 It does have requirements and quirks: firstly, as uniqueness is controlled by
 the identifier, it's up to the consumer to guarantee quality identifiers;
 secondly, while each load call moves a particular request to the top of its
 tier, moving between tiers is unidirectional – a request can only become
 _more important_.
 
 For more information, see KCDRemoteMediaPrivate.h, which contains headers
 and class extensions for the private implementation details.
 
 */

@import Foundation;
@import UIKit;

@class KCDRemoteMedia;

/**
 KCDRemoteMediaOptions provides an interface for customizing the characterstics of load requests.
 KCDRemoteMediaOptionCellularAllowed Download task is permitted to transact over cellular; default is Wifi only.
 KCDRemoteMediaOptionPriorityVeryLow Priority for the load request
 KCDRemoteMediaOptionPriorityLow Priority for the load request
 KCDRemoteMediaOptionPriorityNormal Priority for the load request
 KCDRemoteMediaOptionPriorityHigh Priority for the load request
 KCDRemoteMediaOptionPriorityVeryHigh Priority for the load request
 KCDRemoteMediaOptionDiscretionary The download task may be cancelled by the system, if necessary to free up resources.
 KCDRemoteMediaOptionReplaceOptions Any previous options sent by another consumer will be overwritten with these options, otherwise only options that increase priority (non-discretionary, cellular)
 KCDRemoteMediaOptionSystemSubmitted A convenience option that equates to normal+discretionary (0b 0001 0010 0000)
 KCDRemoteMediaOptionUserSubmitted A convenience option that equates to high+cellular+replace (0b 0001 0000 0011 0001)
 */

typedef NS_OPTIONS(int64_t, KCDRemoteMediaOptions) {
    KCDRemoteMediaOptionNone                        = 0 << 0,
    KCDRemoteMediaOptionCellularAllowed             = 1 << 0,
    KCDRemoteMediaOptionPriorityVeryLow             = 0 << 4,
    KCDRemoteMediaOptionPriorityLow                 = 1 << 4,
    KCDRemoteMediaOptionPriorityNormal              = 2 << 4,
    KCDRemoteMediaOptionPriorityHigh                = 3 << 4,
    KCDRemoteMediaOptionPriorityVeryHigh            = 4 << 4,
    KCDRemoteMediaOptionDiscretionary               = 1 << 8,
    KCDRemoteMediaOptionReplaceOptions              = 1 << 12,
    KCDRemoteMediaOptionProgressUpdates             = 1 << 13, // Trigger progress update blocks. Set automatically, if a progress block is provided.
    KCDRemoteMediaOptionFileCoordination            = 1 << 14, // Coordinate file operations
    KCDRemoteMediaOptionDistributedLoadingQueues    = 1 << 15, // Give each image loading operation its own queue (fast/expensive)
    KCDRemoteMediaOptionSystemSubmitted             = (KCDRemoteMediaOptionPriorityNormal|KCDRemoteMediaOptionDiscretionary),
    KCDRemoteMediaOptionUserSubmitted               = (KCDRemoteMediaOptionPriorityHigh|KCDRemoteMediaOptionCellularAllowed|KCDRemoteMediaOptionReplaceOptions),
};

#if TARGET_OS_IPHONE
UIKIT_EXTERN NSString *__nonnull const kKCDRemoteMediaErrorDomain;
UIKIT_EXTERN NSInteger const kKCDRemoteMediaMaxOperationCount;
#else
FOUNDATION_EXPORT NSString *__nonnull const kKCDRemoteMediaErrorDomain;
FOUNDATION_EXPORT NSInteger const kKCDRemoteMediaMaxOperationCount;
#endif

typedef NS_ENUM (NSInteger, KCDRemoteMediaErrorCode) {
    KCDRemoteMediaErrorUndefined = -1,
    KCDRemoteMediaErrorInvalidRequest = 0,
    KCDRemoteMediaErrorInvalidData = 1,
    KCDRemoteMediaErrorInvalidLocalURL = 2,
    KCDRemoteMediaErrorInvalidRemoteURL = 3,
};

@interface KCDRemoteMedia : NSObject

/**
 This request's unique identifier. Used to identify requests and distinguish them from one another.
 */

@property (nonatomic, readonly, copy, nonnull) NSString *identifier;

/**
 The URL request describing the remote resource that this object represents.
 */

@property (nonatomic, readonly, copy, nonnull) NSURLRequest *request;

/**
 The local file URL for this resource.
 @note This method will return the local URL that the file will be stored at, if the file has not been downloaded.
 */

@property (nonatomic, readonly, copy, nonnull) NSURL *localURL;

/**
 Returns YES if the underlying data exists on the device.
 */

@property (nonatomic, readonly) BOOL existsLocally;

/**
 Returns YES if the underlying data already existed on the device.
 Returns NO, if the data was loaded from the network.
 */

@property (nonatomic, readonly) BOOL wasCached;

/**
 Returns the underlying error that caused the media request to fail, if any.
 */

@property (nonatomic, readonly, strong, nullable) NSError *error;


/**
 Returns a new KCDRemoteMedia instance for the request with the given identifier.
 @param request The request that the data wraps.
 @param identifier The unique identifier for this data request.
 @note The identifier for a data request must be unique.
 */

+ (nullable instancetype)mediaForRequest:(nonnull NSURLRequest *)request
                             destination:(nullable NSURL *)fileURL
                              identifier:(nonnull NSString *)identifier;

/**
 Convenience method, where the request URL includes a file name.
 */

+ (nullable instancetype)mediaForRequest:(nonnull NSURLRequest *)request
                              identifier:(nonnull NSString *)identifier;


/**
 Begins the asynchronous data loading operation. If the data exists locally, the completion handler will be called immediately.
 If the data does not exist locally, a download request for the data will be queued, with the most recently invoked request being
 given priority over similarly ranked requests.
 
 @param options An options mask describing request characterstics. Default: system submitted.
 @param progress A block object for download progress. This block is guaranteed to execute on the main queue.
 @param completion A block object that will be called when the download operation completes.
 */

- (void)loadDataWithOptions:(KCDRemoteMediaOptions)options
                   progress:(nullable void(^)(CGFloat progress))progress
                 completion:(nullable void(^)(NSURL *__nullable localURL, NSError *__nullable error))completion;


/**
 Returns the file URL of the root directory in which downloaded data will be saved.
 @note This URL will only be used where the destinationURL parameter was not set.
 */

+ (nonnull NSURL *)dataCacheURL;

void KCDThrowExceptionForIllegalInitializer(void);

- (instancetype)init NS_UNAVAILABLE;

@end
