//
//  PKTRemoteMedia+FileURLs.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 8/25/18.
//  Copyright © 2018 Pocket. All rights reserved.
//


#import "PKTRemoteMedia.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTRemoteMedia (FileURLs)

+ (NSURL *_Nullable)imageURL:(PKTItem *_Nullable)anItem;

+ (NSURL *_Nonnull)rootURL;

+ (NSURL *_Nonnull)thumbnailsURL;

+ (NSURL *_Nonnull)imagesURL;

+ (NSURL *_Nonnull)rawImagesURL;

+ (NSURL *_Nullable)rawImageDirectoryURL:(NSString *)unique;

+ (NSURL *_Nullable)rawImageCacheURL:(NSURL *)remoteURL unique:(NSString *)unique;

+ (NSURL *_Nullable)thumbnailsImageDirectoryURL:(NSString *)grouping size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
