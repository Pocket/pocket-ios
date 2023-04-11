//
//  PKTAVAssetResourceLoader.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import AVFoundation;

#import "PKTKusari+PKTListen.h"
#import "PKTAPIRequestBuild.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTAVAssetResourceLoader;
@class PKTAudioStreamInfo;

@protocol PKTAVAssetResourceLoaderDelegate <NSObject>

- (void)loaderDidLoadAsset:(PKTAVAssetResourceLoader *)loader;
- (void)loaderDidFail:(PKTAVAssetResourceLoader *)loader;
- (void)loaderDidFinish:(PKTAVAssetResourceLoader *)loader;
- (void)loaderDidCancel:(PKTAVAssetResourceLoader *)loader;

@end

@interface PKTAVAssetResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

@property (nonatomic, readonly, assign)   BOOL connectionHasFinishedLoading; // KVO Observable
@property (nonatomic, readonly, strong) PKTKusari<id<PKTListenItem>> *kusari;
@property (nonatomic, readonly, strong) AVURLAsset *asset;
@property (nonatomic, readonly, strong) NSError *error;
@property (nonatomic, readonly, strong) NSURL *localURL;
@property (nonatomic, readonly, strong) NSURL *remoteURL;
@property (nonatomic, readonly, strong, nullable)                   NSURL *tempURL; // No KVO
@property (nonatomic, readwrite, weak) id<PKTAVAssetResourceLoaderDelegate> delegate;
@property (nonatomic, readonly, assign) CGFloat downloadProgress; // KVO observable
@property (nonatomic, readonly, assign, getter=isDownloading) BOOL downloading; // KVO Observable
@property (nonatomic, readonly, assign, getter=hasDownloaded) BOOL hasDownloaded; // KVO Observable

- (instancetype)initWithKusari:(PKTKusari<id<PKTListenItem>> *)kusari
                         asset:(AVURLAsset *)asset;

+ (PKTAPITaskCancel)requestAudioURL:(PKTKusari<id<PKTListenItem>> *)kusari
                         completion:(void(^)(NSArray<PKTAudioStreamInfo*> *audioStreams, NSError *error))completion;

- (void)startDownload;

- (void)loadAssetDuration:(void(^)(NSError *_Nullable error, AVKeyValueStatus status))completion;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
