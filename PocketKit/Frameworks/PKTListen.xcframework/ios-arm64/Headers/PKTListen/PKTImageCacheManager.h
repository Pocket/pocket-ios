//
//  PKTImageCacheManager.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/12/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import UIKit;

#import "PKTRemoteMedia.h"
#import "PKTImageCacheManagement.h"
#import "PKTImageResource.h"

@class PKTRemoteMedia;
@protocol PKTImageResource;

#define PKTImageCacheManagerSimulateDeletions TARGET_OS_SIMULATOR
#define PKTImageCacheManagerValidateFiles TARGET_OS_SIMULATOR

NS_ASSUME_NONNULL_BEGIN

#pragma mark - PKTImageCacheManager

/** PKTImageCacheManager manages a image metadata cache and image files on disk. It has a minimal public API, as most
 interaction are handled internally by PKTRemoteImageCache, and PKTRemoteImage. */

@interface PKTImageCacheManager : NSObject <PKTImageCacheManagement>

@property (nonatomic, readwrite, assign, getter=isDisabled) BOOL disabled;
@property (nonatomic, readonly, assign, getter=isCleaning) BOOL cleaning;
@property (nonatomic, readonly) unsigned long long imageCacheBytes;
@property (nonatomic, readonly) float imageCacheMegabytes;
@property (nonatomic, readwrite, assign) BOOL validateFiles;

+ (instancetype)sharedManager;

- (void)deleteResource:(id<PKTImageResource>)resource options:(PKTRemoteImageDeleteOptions)options;

- (BOOL)isAvailableOffline:(id<PKTImageResource>)resource;

- (void)cleanCache:(unsigned long long)limit strategy:(PKTRemoteImageDeleteOptions)strategy;

- (void)reset;

- (NSDictionary *_Nullable)readImageInfo:(id<PKTImageResource>)resource;

/** Manually write image data to the image cache.
 The format of the image dictionary, is as follows:
 
 {
    // NSDate: Set automatically – do not provide
    date = "2018-09-22 20:21:56 +0000";
    // NSNumber: 1 if the raw image exists on disk, otherwise 0 or the pair may be excluded
    downloaded = 1;
    // NSNumber: one of the PKTRemoteMediaFailureReason types
    failure = 0;
    // NSString: the relative path to the raw image in [PKTRemoteMedia rootURL]
    localRawURL = "images/raw/2246974786/1*49DDRZhUWvVnH-QNHuSUSw.png";
    // NSString: the item_id of the item to which the image belongs
    resourceID = 2246974786;
    // NSString: the image resource URL
    resourceURL = "https://cdn-images-1.medium.com/max/2000/1*49DDRZhUWvVnH-QNHuSUSw.png";
    // NSDictionary: thumbnails that currently exist on disk. The key is the size, the value is the relative
    // path from [PKTRemoteMedia rootURL].
    thumbnails =     {
        NSValue/CGSize     =  NSString of relative path from [PKTRemoteMedia rootURL]
        "NSSize: {90, 90}" = "images/thumbnails/2246974786/90_90/1*49DDRZhUWvVnH-QNHuSUSw.jpeg";
    };
 }
 
 IMPORTANT: to maintain cache integrity, use the `deleteResource:options:` method to removed cached images, or manually
 update this image information to reflect data states on disk.

*/

- (void)writeImageInfo:(NSDictionary *_Nullable)imageInfo resource:(id<PKTImageResource>)resource;

- (void)deleteEphemeralImages;

@end

#pragma mark - PKTRemoteImageCache

/** PKTRemoteImageCache is a wrapper around PKTRemoteMedia and PKTImageCacheManager. It is intended to provide a block-based
 API for quickly retrieving images from the fastest source. PKTRemoteImageCache uses the PKTImageCacheManager to validate
 the image resource, and will return nil for images that are permanently unavailable, or not ready for another
 download attempt.*/

@interface PKTRemoteImageCache : NSObject

/** @return YES if the raw resource is available offline. */
@property (nonatomic, readonly, assign) BOOL isAvailableOffline;
/** @return YES if the raw resource is reachable over the network and is eligible for download */
@property (nonatomic, readonly, assign) BOOL canDownload;
/** @return NO if the image download previously failed, and we're not ready to retry.*/
@property (nonatomic, readonly, assign) BOOL isValid;
/** @return NSDate of next load attempt, if any. */
@property (nonatomic, readonly, weak, nullable) NSDate *nextAttempt;

+ (nullable instancetype)remoteImageCache:(nullable id<PKTImageResource>)resource; // will/can return nil

- (void)load:(CGSize)size
     options:(KCDRemoteMediaOptions)options
  completion:(nullable void(^)(PKTRemoteMedia *_Nullable media))completion;

+ (BOOL)hasImage:(id<PKTImageResource>)resource;

@end

#pragma mark - PKTRemoteImage

/** PKTRemoteImage is a KVO-compliant subclass of PKTRemoteImageCache. It's slightly easier to use, because the consumer
 doesn't need to check that the image loaded is the same image requested, as she would in the completion handler of
 PKTRemoteImageCache. */

@interface PKTRemoteImage : PKTRemoteImageCache

/** @return the size of image */
@property (nonatomic, readonly, assign) CGSize size;
/** @return NO, if the image doesn't currently exist at this size; otherwise, YES
@note This should not be confused with the availability of the raw image. */
@property (nonatomic, readonly, assign) BOOL isAvailable;
/** @return the image resource, if loaded.
 @note The property will be nil until the load method is called, after which point it is retained.*/
@property (atomic, readonly, strong, nullable) UIImage *image; // KVO Observable

+ (nullable instancetype)remoteImage:(nullable id<PKTImageResource>)resource size:(CGSize)size;

- (void)load:(KCDRemoteMediaOptions)options;

@end

NS_ASSUME_NONNULL_END
