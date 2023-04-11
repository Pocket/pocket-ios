//
//  PKTAudibleItemCache.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 2/9/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import Foundation;

@class IGListSectionController;
@class PKTAudioStreamInfo;
@class PKTAVAssetResourceLoader;
@class PKTAudioStream;

@protocol PKTListenPlayerState;

#import "PKTKusari+PKTListen.h"

typedef NS_OPTIONS(NSInteger, PKTAudioStreamDeleteOptions) {
    PKTAudioStreamDeleteOptionsDeleteNone          = 0,
    PKTAudioStreamDeleteOptionsDeleteFiles         = 1 << 0,
    PKTAudioStreamDeleteOptionsDeleteMetadata      = 1 << 1,
    PKTAudioStreamDeleteOptionsDeleteProgress      = 1 << 2,
    PKTAudioStreamDeleteOptionsDeleteOrphanData    = PKTAudioStreamDeleteOptionsDeleteFiles,
    PKTAudioStreamDeleteOptionsDeleteEverything    = (PKTAudioStreamDeleteOptionsDeleteFiles
                                                      |PKTAudioStreamDeleteOptionsDeleteMetadata
                                                      |PKTAudioStreamDeleteOptionsDeleteProgress)
};

NS_ASSUME_NONNULL_BEGIN

@protocol PKTAudibleItemCache<NSObject>

@property (nonatomic, readwrite, assign) NSInteger maximumWordCount;
@property (nonatomic, readwrite, assign) NSInteger minimumWordCount;
@property (nonatomic, readwrite, assign) NSInteger playbackSpeedFactor;
@property (nonatomic, readwrite, nonnull, strong) NSSet<NSString*> *supportedLanguages;
@property (nonatomic, readwrite, nonnull, strong) NSSet<NSString*> *supportedFormats;
@property (nonatomic, readonly, assign) BOOL hasUsedListen;
@property (class, nonatomic, readwrite, assign, getter=isDisabled) BOOL disabled;

+ (instancetype)sharedManager;

/**
 The fileURL representation of the directory in which downloaded streams are stored.
 */

+ (NSURL *_Nonnull)localStreamCacheDirectoryURL;

#pragma mark - Records

- (CGFloat)position:(NSString *)albumID;

- (CMTime)currentTime:(NSString *)albumID;

- (CMTime)duration:(NSString *)albumID;

#pragma mark - Kusari

- (BOOL)hasDownloaded:(PKTKusari<id<PKTListenItem>>*)kusari;

+ (NSURL *_Nullable)remoteStreamProxyURI:(PKTKusari<id<PKTListenItem>>*)kusari;

#pragma mark - PKTAudioStream

- (void)updateStreamPlaybackState:(PKTAudioStream *)stream;

- (void)updateStreamPlaybackDate:(PKTAudioStream *)stream;

- (void)playbackDidFinish:(PKTAudioStream *)stream;

- (void)playbackDidPersist:(PKTAudioStream *)stream;

- (void)assetLoaderDidFinish:(PKTAVAssetResourceLoader *)loader;

#pragma mark - PKTAudioStreamsInfo

- (PKTAudioStreamInfo *_Nullable)info:(PKTAudioStream *)stream;

+ (NSURL *_Nullable)suggestedLocalCacheURL:(PKTAudioStreamInfo *)stream;

- (NSArray<PKTAudioStreamInfo*> *_Nullable)streamsInfo:(NSString *)albumID;

- (void)updateStreamsInfo:(NSArray<PKTAudioStreamInfo*> *)streamsInfo;

- (NSURL *_Nullable)localStreamFileURL:(PKTAudioStreamInfo *)streamInfo validate:(BOOL)validate;

- (unsigned long long)deleteStream:(PKTAudioStreamInfo *)streamInfo
                           options:(PKTAudioStreamDeleteOptions)options;

// Used on iOS 10 to pre-download streams from a PKTAudioStreamInfo instance.
- (PKTAudioStreamInfo *_Nullable)playbackDidDownload:(PKTAudioStreamInfo *)stream toURL:(NSURL *)localURL;

- (NSInteger)sweep;

#pragma mark - Cells

- (void)setCellSize:(CGSize)size
             kusari:(PKTKusari<id<PKTListenItem>> *)kusari
               cell:(UICollectionViewCell *)cell
      containerSize:(CGSize)containerSize;

- (CGSize)cellSize:(PKTKusari<id<PKTListenItem>> *)kusari
              cell:(UICollectionViewCell *)cell
     containerSize:(CGSize)containerSize;

#pragma mark - Cache Control

+ (unsigned long long)audioCacheBytes;

+ (float)audioCacheMegabytes;

+ (void)cleanCache:(unsigned long long)limit strategy:(PKTAudioStreamDeleteOptions)strategy;

- (void)purgeCellCache;

- (void)reset;

#pragma mark - PKTListenItem

- (void)updateKusari:(PKTKusari<id<PKTListenItem>> *)kusari withState:(id<PKTListenPlayerState>)state;

@end

NS_ASSUME_NONNULL_END
