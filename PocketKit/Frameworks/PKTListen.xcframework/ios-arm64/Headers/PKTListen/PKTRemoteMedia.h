//
//  PKTRemoteMedia.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 8/14/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "KCDRemoteMedia.h"
#import "PKTImageResource.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTItem;

typedef NS_ENUM(NSInteger, PKTRemoteMediaFailureReason) {
    PKTRemoteMediaFailureReasonNone,
    PKTRemoteMediaFailureReasonUnknown,
    PKTRemoteMediaFailureReasonTimedOut,
    PKTRemoteMediaFailureReasonNetworkFailed,
    PKTRemoteMediaFailureReasonResourceDoesNotExist,
    PKTRemoteMediaFailureReasonResourceSSL,
    PKTRemoteMediaFailureReasonResourceIO,
    PKTRemoteMediaFailureReasonImageProcessing,
    PKTRemoteMediaFailureReasonUnrecognizedImageType,
};

@interface PKTRemoteMedia : NSObject

@property (nonatomic, readonly, assign) CGFloat scale;

@property (nonatomic, readonly, assign) CGSize actualSize;

@property (nonatomic, readonly, assign) CGSize requestedSize;

/**
 @return YES, if this image was loaded directly from disk
 */

@property (nonatomic, readonly, assign) BOOL didLoadFromCache;

/**
 @return YES, if this image was downloaded this session.
 */

@property (nonatomic, readonly, assign) BOOL isFresh;

/**
 The underlying cause of the failure, if any.
 */

@property (nonatomic, readonly, assign) PKTRemoteMediaFailureReason failureReason;

/**
 @return The underlying error that caused the media request to fail, if any.
 */

@property (nullable, nonatomic, readonly, strong) NSError *error;

/**
 @return the itemID of the item associated with a given media object.
 @note This will not be the same as the uniqueID value.
 @note This value is non-nill only for thumbnail requests made through the loadThumbnail: convenience method.
 */

@property (nullable, nonatomic, readonly, strong) NSString *itemID;

/**
 @return the uniqueID of the associated with a given media object.
 */

@property (nullable, nonatomic, readonly, strong) NSString *uniqueID;

/**
 @return URL of the resized thumbnail asset on disk.
 */

@property (nullable, nonatomic, readonly, strong) NSURL *cacheURL;

/**
 @return URL of the origin URL from which the asset was requested.
 */

@property (nullable, atomic, readonly, strong) NSURL *remoteURL;

/**
 @return URL of the original, unmodified asset on disk.
 */

@property (nullable, nonatomic, readonly, strong) NSURL *rawURL;

/**
 @return UIImage loaded from the media's cacheURL.
 @note This is a lazy loaded value. Messaging this property will load the underlying image into memory, if it hasn't already been.
 */

@property (nullable, nonatomic, readonly, strong) UIImage *image;

/**
 @return YES if the image has already been loaded from disk; otherwise, NO.
 @note Use this property to determine if there will a performance cost associated with accessing the image property
 */

@property (nonatomic, readonly) BOOL imageIsLoaded;

/**
 If set to YES before the first media request, the images directory will be erased and all requests will download new media
 */

@property (nonatomic, readwrite, assign, class) BOOL debugModeEnabled;

/**
 @param resource The image resource to download. The resource's imageResourceURL will be used as the request's unique ID
 @param maxSize The size that the process thumbnail should be constrained to. If the value is CGZero, the image will not be resized
 @param options An options mask to control priority
 @param completion An optional block to be called when the request is complete
 @note The block will not be called if the input parameters are invalid.
 @return A PKTRemote media object, if the parameters were valid. Otherwise, nil
 */

+ (nullable PKTRemoteMedia *)loadImageResource:(id<PKTImageResource>)resource
                                          size:(CGSize)maxSize
                                       options:(KCDRemoteMediaOptions)options
                                    completion:(nullable void(^)(PKTRemoteMedia *_Nonnull media))completion;

+ (PKTRemoteMedia *)localMedia:(id<PKTImageResource>)resource localURL:(NSURL *)localURL;

UIImage * writeThumbnail(CGFloat maxSpan, CGFloat scale, NSURL *origin, NSURL *target, CFStringRef UTI, NSDictionary *imageProperties);

NSString * typeOfImageAtURL(NSURL *imageURL);

CGSize imageSize(NSURL *imageURL, CGFloat scale);

NSString * imageExtensionForType(CFStringRef UTI);

NSDictionary * imageProperties(NSURL *imageURL);

@end

NS_ASSUME_NONNULL_END
