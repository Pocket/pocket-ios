//
//  PKTAudioStream.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 7/30/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;
@import AVFoundation;

#import "PKTKusari.h"
#import "PKTListenItem.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTAudioStreamInfo;
@class PKTAudioStream;
@class PKTKusari;
@class PKTAVAssetResourceLoader;

@protocol PKTListenItem;

@protocol PKTAudioStreamDelegate <NSObject>

@optional

- (AVPlayer *)playerForKusari:(nonnull PKTAudioStream *)stream;

@required

- (void)playbackCanPlay:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidDownload:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidFinish:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidStall:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidLoad:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidFail:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidCancel:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;
- (void)playbackDidUpdate:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;

@end

typedef NS_ENUM(NSInteger, PKTAudioStreamType) {
    PKTAudioStreamTypeUndefined,
    PKTAudioStreamTypeUnresolvedResource,
    PKTAudioStreamTypeRemoteResource,
    PKTAudioStreamTypeLocalResource,
};

typedef NS_ENUM(NSInteger, PKTAudioStreamState) {
    PKTAudioStreamStateUndefined,
    PKTAudioStreamStateNone,
    PKTAudioStreamStateRequestedURL,
    PKTAudioStreamStateRequestedStream,
    PKTAudioStreamStateLoading,
    PKTAudioStreamStateLoaded,
    PKTAudioStreamStateDownloading,
    PKTAudioStreamStateFailed,
    PKTAudioStreamStateFinished,
};

typedef NS_ENUM(NSInteger, PKTAudioStreamErrorCode) {
    PKTAudioStreamErrorCodeUndefined,
    PKTAudioStreamErrorCodeInvalidStreamURL,
};

@interface PKTAudioStream : AVPlayerItem

@property (nonatomic, readonly, strong, nullable) PKTKusari<id<PKTListenItem>> *kusari;

@property (nonatomic, readwrite, weak, nullable) id<PKTAudioStreamDelegate> delegate;

@property (nonatomic, readonly, strong, nullable) PKTAVAssetResourceLoader *loader;

@property (nonatomic, readonly, assign) PKTAudioStreamType type;

@property (nonatomic, readonly, assign) CGFloat playbackProgress;

@property (nonatomic, readonly, assign, getter=isPlaying) BOOL playing;

@property (nonatomic, readonly, assign, getter=isLoaded)  BOOL loaded;

@property (nonatomic, readonly, assign, getter=isDownloading) BOOL downloading;

@property (nonatomic, readonly, assign) CGFloat downloadProgress;

@property (nonatomic, readonly, assign) CMTime timeBuffered;

+ (nullable instancetype)streamWithKusari:(PKTKusari<id<PKTListenItem>> *)kusari;

+ (void)loadStream:(PKTKusari<id<PKTListenItem>> *)kusari
        completion:(void(^)(NSError *_Nullable error, PKTAudioStream *_Nullable stream))completion;

- (nullable instancetype)initWithKusari:(PKTKusari<id<PKTListenItem>> *)kusari
                                 stream:(PKTAudioStreamInfo *)streamInfo
                                   type:(PKTAudioStreamType)type NS_DESIGNATED_INITIALIZER;

- (void)updateKusari:(PKTKusari<id<PKTListenItem>> *)kusari;

- (void)destroy;

- (instancetype)initWithAsset:(AVAsset *)asset __unavailable;

+ (instancetype)playerItemWithAsset:(AVAsset *)asset __unavailable;

+ (instancetype)playerItemWithURL:(NSURL *)URL __unavailable;

+ (instancetype)playerItemWithAsset:(AVAsset *)asset automaticallyLoadedAssetKeys:(NSArray<NSString *> *_Nullable)automaticallyLoadedAssetKeys __unavailable;


@end

NS_ASSUME_NONNULL_END
