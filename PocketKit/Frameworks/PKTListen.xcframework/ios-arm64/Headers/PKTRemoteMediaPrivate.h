//
//  PKTRemoteMediaPrivate.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 8/25/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#ifndef PKTRemoteMediaPrivate_h
#define PKTRemoteMediaPrivate_h

#endif /* PKTRemoteMediaPrivate_h */

NS_ASSUME_NONNULL_BEGIN

@interface KCDRemoteMedia (PKTRemoteMedia)

@property (nullable, nonatomic, readwrite, strong) NSError *error;

@end

@interface PKTRemoteMedia()

@property (nonatomic, readwrite, assign) BOOL didLoadFromCache;
@property (nullable, nonatomic, readwrite, strong) NSString *uniqueID;
@property (nullable, nonatomic, readwrite, strong) NSString *itemID;
@property (nullable, nonatomic, readwrite, strong) NSError *error;
@property (nullable, nonatomic, readwrite, strong) NSURL *cacheURL;
@property (nullable, nonatomic, readwrite, strong) NSURL *rawURL;
@property (nullable, atomic, readwrite, strong) NSURL *remoteURL;
@property (nullable, nonatomic, readwrite, strong) UIImage *image;
@property (nonatomic, readwrite, assign) CGSize requestedSize;
@property (nonatomic, readwrite, assign) CGSize actualSize;
@property (nonatomic, readwrite, assign) CGFloat scale;
@property (nonatomic, readwrite, assign) BOOL isFresh;

@end

NS_ASSUME_NONNULL_END
