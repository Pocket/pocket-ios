//
//  PKTListenItem.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/25/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;

#import "PKTKusari.h"
#import "PKTRemoteMedia.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PKTListenItem <PKTListDiffable, PKTImageResource>

@property (nullable, nonatomic, readonly, copy) NSString *albumID;
@property (nullable, nonatomic, readonly, copy) NSString *localAlbumID;
@property (nullable, nonatomic, readonly, copy) NSString *albumTitle;
@property (nullable, nonatomic, readonly, copy) NSString *albumArtist;
@property (nullable, nonatomic, readonly, copy) NSString *albumStudio;
@property (nullable, nonatomic, readonly, copy) NSString *albumLanguage;
@property (nonatomic, readonly, assign) NSTimeInterval estimatedAlbumDuration;
@property (nullable, nonatomic, readonly, copy) NSURL *albumArtRemoteURL;

@property (nonatomic, readonly, assign) BOOL canArchiveAlbum;
@property (nonatomic, readonly, assign) BOOL hasAlbumArt;
@property (nonatomic, readonly, assign) BOOL albumArtIsAvailableOffline;

@property (nullable, nonatomic, readonly, copy) NSDictionary<NSString*, id> *albumJSON;

// TTS

@property (nonatomic, readonly, strong, nullable) NSURL *givenURL;
@property (nonatomic, readonly, strong, nullable) NSString *localID;

@end

NS_ASSUME_NONNULL_END
