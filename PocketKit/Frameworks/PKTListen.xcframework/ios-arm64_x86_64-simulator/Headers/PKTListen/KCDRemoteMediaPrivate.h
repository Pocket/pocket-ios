//
//  KCDRemoteMediaPrivate.h
//
//  Created by Nik on 4/14/15.
//
//

@import Foundation;
@import MobileCoreServices;

#ifndef KCDRemoteMediaPrivate_h
#define KCDRemoteMediaPrivate_h

@class KCDRemoteMedia, KCDRemoteMediaDispatchStack, KCDRemoteMediaDownloadOperation, KCDRemoteMediaExpectation;

#pragma mark - Utilties -

/**
 A handful of utility methods for quickly working with options bitfield.
 */


// These utility methods are used internally. They provide little utility to a public consumer.

/**
 @return the NSComparisonResult of NSOperationQueuePriority values from the provided options.
 */

NSComparisonResult optionsCompareOperationQueuePriority(KCDRemoteMediaOptions options1, KCDRemoteMediaOptions options2);

/**
 @return the NSInteger value of the options operation queue priority value, from 0-4.
 @note The integer value represents the value expressed in KCDAsynchronousOptions.
 */

int64_t optionsCheckPriorityValue(KCDRemoteMediaOptions options);

/**
 @return the NSOperationQueuePriority value of the options.
 */

NSOperationQueuePriority optionsCheckOperationQueuePriority(KCDRemoteMediaOptions options);

/**
 @return YES if the operation is discretionary.
 */

BOOL optionsCheckDiscretionary(KCDRemoteMediaOptions options);

/**
 @return YES if the options allow for cellular downloads.
 */

BOOL optionsCheckCellularAllowed(KCDRemoteMediaOptions options);

/**
 @return YES if the options should replace previous options.
 */

BOOL optionsCheckReplaceOptions(KCDRemoteMediaOptions options);

/**
 Returns the component of a URL that is likely to represent a file name, or nil if the URL does not clearly end with a file name.
 @return The name of the file that the URL's last path component represents.
 @param URL The URL to examine.
 @param UTI If a file name is returned, the UTI of the file type; otherwise, none.
 @note This method will return a file name if the following two conditions are met: (1) the last path component of the URL has a path exentsion, and; (2) the system returns a preexisting UTI for that path extension. This is a best guess system only.
 */

NSString *__nullable remoteFileNameForURL(NSURL *__nonnull URL, NSString *__autoreleasing __nullable *__nullable UTI);

#pragma mark - <KCDRemoteMediaProtocol>

@protocol KCDRemoteMediaProtocol <NSObject>

- (nullable instancetype)initWithRequest:(nonnull NSURLRequest *)request
                             destination:(nullable NSURL *)fileURL
                              identifier:(nonnull NSString *)identifier;

- (nullable instancetype)initWithRequest:(nonnull NSURLRequest *)request
                              identifier:(nonnull NSString *)identifier;

@end

/************************************************/
/*              KCDRemoteMedia              */
/************************************************/


#pragma mark - KCDRemoteMedia Class Extension -

/**
 KCDRemoteMedia is a facade: there may be several instances of the class, all of which are backed by the
 same download operation and expectation queue. Most of its properties are dynamically derived, making it a
 light weight proxy.
 */

@interface KCDRemoteMedia() <KCDRemoteMediaProtocol> {
    // The dispatch_once token used for setting up the loading dispatch queue and cache.
    dispatch_once_t _loadingDispatchSetupToken;
    // The serial queue used for safe access to the loading dispatch cache.
    dispatch_queue_t _loadingDispatchSerialQueue;
    // The local URL spawn.
    dispatch_once_t _localURLSpawn;
}

/**
 A scalar value to capture download state.
 */

@property (nonatomic, readwrite, assign, getter=isDownloading) BOOL downloading;

- (nullable instancetype)initWithRequest:(nonnull NSURLRequest *)request
                             destination:(nullable NSURL *)fileURL
                              identifier:(nonnull NSString *)identifier NS_DESIGNATED_INITIALIZER;

- (nullable instancetype)initWithRequest:(nonnull NSURLRequest *)request
                              identifier:(nonnull NSString *)identifier;

/**
 Returns YES if these data share a common identifier.
 */

- (BOOL)isEqual:(nullable id)object;

@end


/************************************************/
/*        KCDRemoteMediaDispatchStack       */
/************************************************/


#pragma mark - KCDRemoteMediaDispatchStack Interface -

@interface KCDRemoteMediaDispatchStack : NSObject

/**
 @return A singleton instance of the data dispatch stack. An application needs only one.
 */

+ (nonnull instancetype)sharedStack;

/**
 @return YES, if an download operation exists for the given identfier; otherwise, NO.
 @note This method is thread safe.
 */

- (BOOL)operationExistsForIdentifier:(nonnull NSString *)identifier;

/**
 Pushes an asynchronous data instance onto the stack. This will create a download operation,
 if necessary.
 
 @param asyncData An KCDRemoteMedia facade describing the data to be downloaded.
 @param options A bitfield describing operational characterstics. If a download operation already exists for the given identifier, the options parameter will be applied to that operation.
 @param expectation A KCDRemoteMediaExpectation that wraps a progress handler and completion block, both of which will be linked to the operation's progress.
 */


- (void)pushRemoteMedia:(nonnull KCDRemoteMedia<KCDRemoteMediaProtocol>*)asyncData
                 options:(KCDRemoteMediaOptions)options
             expectation:(nonnull KCDRemoteMediaExpectation *)expectation;

/**
 Pops up to maxPopCount of pending download operations off of the stack and into the download operation queue.
 @param maxPopCount The maximum number of download operations to pop.
 */

- (void)popAsynchronousData:(NSInteger)maxPopCount;

@end

#pragma mark - KCDRemoteMediaDispatchStack Class Extension -

@interface KCDRemoteMediaDispatchStack()

+ (void)pushRemoteMedia:(nonnull KCDRemoteMedia<KCDRemoteMediaProtocol>*)asyncData
                 options:(KCDRemoteMediaOptions)options
                   queue:(nonnull dispatch_queue_t)queue
                   stack:(nonnull NSMutableOrderedSet *)stack
                   cache:(nonnull NSCache *)cache
             expectation:(nonnull KCDRemoteMediaExpectation *)expectation;

+ (void)popAsynchronousData:(NSInteger)maxPopCount
                      queue:(nonnull dispatch_queue_t)queue
                      stack:(nonnull NSMutableOrderedSet *)stack
                      cache:(nonnull NSCache *)cache
                   download:(nonnull NSOperationQueue *)download;

@end

#pragma mark - KCDRemoteMediaDownloadCompletion Interface -

/**
 KCDRemoteMediaDownloadCompletion is a private class that wraps a simple completion handler. Its primary purpose is to allow us to accumulate completion handlers, the execution of which are dependent on a single asynchronous operation.
 
 Dependent NSOperations closely track this design pattern. However, dependent operations are isolated, and cannot share information between one another. This is a limitation where the tasks share an interest in a common data structure, for which we do not want to have more than a single instance in memory, and we don't want that instance to persist in memory for longer than its interested parties.
 
 Notifications would be another option, but where we can anticipate frequent callbacks, in the form of progress updates, the number of notifications posted, and registrations, begins to loom large.
 */


/************************************************/
/*        KCDRemoteMediaExpectation         */
/************************************************/


#pragma mark - KCDRemoteMediaExpectation Interface -

@interface KCDRemoteMediaExpectation : NSObject {
@public BOOL _wasFirstDownload;
}

/**
 @return YES, if the expectation has been met; otherwise, NO.
 */

@property (nonatomic, readonly, assign) BOOL isComplete;

/**
 @return YES, if this expectation was the first download request.
 */

@property (nonatomic, readonly, assign) BOOL wasFirstDownload;

/**
 Creates a new KCDRemoteMediaExpectation with the provided progress and completion blocks.
 @param progress A progress block that will be called repeatedly as the download progresses.
 @param completion A block object that will be called when the download operation completes, or fails.
 */

- (nonnull instancetype)initWithProgress:(nullable void(^)(CGFloat progress))progress
                              completion:(nonnull void(^)(KCDRemoteMediaExpectation *_Nullable expectation,
                                                          NSURL *__nullable location,
                                                          NSError *__nonnull error))completion NS_DESIGNATED_INITIALIZER;

/**
 Update the expectation's progress block.
 @param progress The current progress of the download.
 */

- (void)updateWithProgress:(CGFloat)progress;

/**
 Triggers the expectation's completion block.
 @note An expectation's completion block can only be triggered once, subsequent attempts to complete the expectation will have no result.
 */

- (void)completeWithLocation:(nullable NSURL *)location
                       error:(nullable NSError *)error;

@end


#pragma mark - KCDRemoteMediaExpectation Class Extension -

/**
 An KCDRemoteMediaExpectation wraps the progress and completion blocks provided by an interested observer.
 It has very little utility beyond providing an interface by which to trigger those blocks.
 */

@interface KCDRemoteMediaExpectation() {
    // Guarantee that the completion block is only ever fired once per instance.
    dispatch_once_t _completionFireToken;
}

@property (nonatomic, readonly, copy, nonnull) void(^completion)(KCDRemoteMediaExpectation *__nullable, NSURL *__nullable, NSError *__nullable);
@property (nonatomic, readonly, copy, nullable) void(^progress)(CGFloat);

@end

/************************************************/
/*     KCDRemoteMediaDownloadOperation      */
/************************************************/

#pragma mark - KCDRemoteMediaDownloadOperation Interface -

/**
 KCDRemoteMediaDownloadOperation is a simple NSOperation subclass that wraps a NSURLSessionDownloadTask.
 It's primary utility is in allowing us to use an NSOperationQueue as a queuing and monitoring mechanism
 for ongoing downloads.
 */

@interface KCDRemoteMediaDownloadOperation : NSOperation

@property (nonatomic, readonly, copy, nonnull) NSString *identifier;
@property (nonatomic, readonly, copy, nonnull) NSURLRequest *request;
@property (nonatomic, readonly, copy, nullable) NSURL *destinationURL;
@property (atomic, readonly, assign, getter=wasSuccessful) BOOL successful;
@property (atomic, readwrite, assign) KCDRemoteMediaOptions options;

- (nullable instancetype)initWithRequest:(nonnull NSURLRequest *)request
                              identifier:(nonnull NSString *)identifier
                             destination:(nonnull NSURL *)destinationURL
                             expectation:(nonnull KCDRemoteMediaExpectation *)completion NS_DESIGNATED_INITIALIZER;

/**
 Adds a given expectation to the operation. When the operation completes, or fails, all its expectations will be met.
 */

- (void)addExpectation:(nonnull KCDRemoteMediaExpectation *)expectation;

/**
 Returns YES if the operations have a common identifier.
 */

- (BOOL)isEqual:(nullable id)object;

@end

#pragma mark - KCDRemoteMediaDownloadOperation Class Extension -

@interface KCDRemoteMediaDownloadOperation() <NSURLSessionDownloadDelegate> {
@protected  dispatch_queue_t _accessQueue;
@protected BOOL _accessSpawn;
@protected BOOL _sessionSpawn;
@protected BOOL _startToken;
@protected BOOL _endToken;
@protected BOOL _successful;
}

@property (nonatomic, readonly, strong, nonnull) NSMutableOrderedSet *expectationCache;
@property (atomic, readwrite, assign) BOOL operationIsExecuting;
@property (atomic, readwrite, assign) BOOL operationIsFinished;

- (void)accessExpectations:(nonnull void(^)(NSOrderedSet *__nonnull expectations))access;

- (void)enumerateExpectationsUsingBlock:(nonnull void(^)(KCDRemoteMediaExpectation *__nonnull expectation, NSUInteger idx, BOOL *__nonnull stop))block;

- (void)completeExpectationsWithLocation:(nullable NSURL *)location
                                   error:(nullable NSError *)error;

@end

#pragma mark - KCDRemoteMediaExpressDownloadOperation Interface -

@interface KCDRemoteMediaExpressDownloadOperation : KCDRemoteMediaDownloadOperation

@end

#endif
