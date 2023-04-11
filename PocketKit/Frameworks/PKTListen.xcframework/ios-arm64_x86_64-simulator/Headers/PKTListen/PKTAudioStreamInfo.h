//
//  PKTAudioStreamInfo.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/17/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import Foundation;

#import "PKTJSONParser.h"
#import "PKTKusari.h"
#import "PKTListenItem.h"

@protocol PKTAudibleItemCache;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - PKTAudioStreamInfo

typedef NS_ENUM(NSInteger, PKTAudioStreamFormat) {
    PKTAudioStreamFormatUndefined,
    PKTAudioStreamFormatOpus,
    PKTAudioStreamFormatMP3,
};

typedef NS_ENUM(NSInteger, PKTAudioStreamStatus) {
    PKTAudioStreamStatusUndefined,
    PKTAudioStreamStatusProcessing,
    PKTAudioStreamStatusAvailable,
};

typedef NS_ENUM(NSInteger, PKTAudioStreamVoice) {
    PKTAudioStreamVoiceUndefined,
    PKTAudioStreamVoiceSalli,
};

@interface PKTAudioStreamInfo : NSObject <NSCopying>

@property (nonatomic, readonly, assign) unsigned long long length;
@property (nonatomic, readonly, assign) NSTimeInterval duration;
@property (nonatomic, readonly, assign) PKTAudioStreamFormat format;
@property (nonatomic, readonly, assign) PKTAudioStreamStatus status;
@property (nonatomic, readonly, assign) PKTAudioStreamVoice voice;
@property (nonatomic, readonly, assign, getter=isDownloaded) BOOL downloaded;
@property (nonatomic, readonly, strong, nullable) NSURL *streamURL;
@property (nonatomic, readonly, strong, nonnull) NSString *albumID;
@property (nonatomic, readonly, strong, nullable) NSURL *localFileURL;
@property (nonatomic, readonly, strong, nullable) NSDate *downloadedDate;
@property (nonatomic, readonly, strong, nullable) NSDate *metadataDate;
@property (nonatomic, readonly, strong, nullable) NSDate *lastPlaybackDate;
@property (nonatomic, readonly, copy, nullable, class) PKTJSONPathTransformation (^dictionaryToStreamInfo)(NSString *albumID, id<PKTAudibleItemCache> cache);
@property (nonatomic, readonly, strong, nonnull) NSDictionary<NSString*, id> *dictionaryRepresentation;

NSString *_Nonnull PKTAudioStreamStatusDescription(PKTAudioStreamStatus v);
NSString *_Nonnull PKTAudioStreamFormatDescription(PKTAudioStreamFormat v);
NSString *_Nonnull PKTAudioStreamVoiceDescription(PKTAudioStreamVoice v);
PKTAudioStreamFormat PKTAudioStreamFormatFromString(NSString *_Nullable rawValue);
PKTAudioStreamStatus PKTAudioStreamStatusFromString(NSString *_Nullable rawValue);
PKTAudioStreamVoice PKTAudioStreamVoiceFromString(NSString *_Nullable string);

+ (PKTAudioStreamInfo *_Nullable)fromDictionary:(NSDictionary *)userInfo cache:(id<PKTAudibleItemCache>)cache;

+ (PKTAudioStreamInfo *)fromKusari:(PKTKusari<id<PKTListenItem>> *)kusari;

- (BOOL)belongsToKusari:(PKTKusari<id<PKTListenItem>> *)kusari;

@end

NS_ASSUME_NONNULL_END
