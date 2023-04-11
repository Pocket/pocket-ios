//
//  PKTListen.h
//  Listen
//
//  Created by Nicholas Zeltzer on 7/27/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;
@import UIKit;
@import MediaPlayer;

// GENERAL

// TODO: Need a download management class. The hack of having streams as object properties has outlived its usefulness

// AUDIO STREAMS
// TODO: if connection lost, fall back to highest quality downloaded stream
// TODO: libopus support

// IMAGE CACHE
// TODO: should use source URLs as identifiers

// STREAM CACHE:
// TODO: decrease cache hits for item URLs

// UI:
// TODO: Enable UICollectionViewDataSourcePrefetching
// TODO: waiting on Design for active button state images

// NETWORKING
// Background downloads for streams
// Anticipatory loading for thumbs over 3G

// When enabled, Listen does stuff
#define PKTListenEnabled 1

// When enabled, thumbnail download rates are suppressed on low bandwidth connections
UIKIT_EXTERN BOOL const PKTListenAnticipatoryThumbnailLoadingEnabled;

// When enabled, Opus stream are available for playback
UIKIT_EXTERN BOOL const PKTListenOpusEnabled;

// When enabled, logs a running list of which items have been excluded and why.
UIKIT_EXTERN BOOL const PKTListenFilterDebuggingEnabled;

// When enabled, stores cell sizes in audible item cache
UIKIT_EXTERN BOOL const PKTListenAudibleItemSectionCellSizeCacheEnabled;

// When enabled, stream files are deleted automatically after they have been finished.
UIKIT_EXTERN BOOL const PKTListenAutomaticallyDeleteFinishedStreams;

// When enabled, the audio stream cache will be kept beneath the PKTListenAudioStreamCacheLimit
UIKIT_EXTERN BOOL const PKTListenEnforceAudioStreamCacheLimit;

// Sets the size (in bytes) of the audio stream cache
UIKIT_EXTERN unsigned long long const PKTListenAudioStreamCacheLimit;

// When enabled, the image thumbnail cache will be kept beneath the PKTListenThumbnailCacheLimit
UIKIT_EXTERN BOOL const PKTListenEnforceThumbnailCacheLimit;

// Sets the size (in bytes) of the thumbnail cache
UIKIT_EXTERN unsigned long long const PKTListenThumbnailCacheLimit;

// Experiments

// Various class-specific logging flags
#define PKTAudioStreamLoggingEnabled               0
#define PKTAudibleQueueLoggingEnabled              0
#define PKTAudioStreamPlayerLoggingEnabled         0
#define PKTImageCacheLoggingEnabled                0
#define PKTAudibleItemCacheManagerLoggingEnabled   0

// Various class-specific timer flags
#define PKTAudioStreamTimersEnabled                0
#define PKTRemoteImageTimersEnabled                0
#define PKTImageCacheManagerTimersEnabled          0

// Log out allocations and deallocations. Useful for debugging retain cycles.
#define PKTListenAllocationLoggingEnabled          0

// Various class-specific view debugging flags
#define PKTListenCoverFlowCollectionViewLayoutDebugEnabled 0

#if PKTListenAllocationLoggingEnabled
#define PKTListenAlloc() PKTLog(PKTLogZoneDynamic, LISTEN_CONTEXT, LOG_FLAG_INFO, @"%@ [+]", NSStringFromClass([self class]))
#define PKTListenDealloc() PKTLog(PKTLogZoneDynamic, LISTEN_CONTEXT, LOG_FLAG_INFO, @"%@ [-]", NSStringFromClass([self class]))
#else
#define PKTListenAlloc() do {;} while(0)
#define PKTListenDealloc() do {;} while(0)
#endif

// Randomize locale when converting numbers into strings
#define PKTListenRandomLocale TARGET_OS_SIMULATOR

// Send analytics action events
#define PKTListenAnalyticsEnabled 1
#if !PKTListenAnalyticsEnabled
#warning Listen Analytics are Disabled
#endif

#import "PKTRuntime.h"
#import "PKTBundle.h"

// Services
#import "PKTImageCacheManager.h"
#import "PKTListenItemSession.h"
#import "PKTAVAssetResourceLoader.h"

// Data Source
#import "PKTListenDataSource.h"

// Streams
#import "PKTFeedSource.h"
#import "PKTPocketHitsParser.h"

// TTS
#import "PKTHTMLParser.h"
#import "PKTArticleContent.h"
#import "PKTTextUnit.h"
#import "PKTHTMLPreviewView.h"

// Models
#import "PKTRemoteListSource.h"
#import "PKTAudioStream.h"
#import "PKTAudioStreamInfo.h"
#import "PKTListenPlaybackState.h"

// Caches
#import "PKTListenAudibleItemQueue.h"
#import "PKTListenCacheManager.h"

// Layouts
#import "PKTListenQueueCollectionViewLayout.h"
#import "PKTListenCoverFlowCollectionViewLayout.h"

// View Controllers
#import "PKTDrawerHostViewController.h"
#import "PKTListenQueueViewController.h"
#import "PKTListenCoverFlowViewController.h"
#import "PKTListenPlayerViewController.h"
#import "PKTListenDrawerViewController.h"
#import "PKTListenContainerViewController.h"

// Views
#import "PKTListenPlaybackControlView.h"
#import "PKTListenPlaybackLoadingView.h"
#import "PKTListenAutoSizingLabel.h"
#import "PKTListenPlayerView.h"
#import "PKTListenAudibleItemThumbnailView.h"
#import "PKTLetterPressView.h"
#import "PKTListenMessageView.h"

// Cells

#import "PKTListenExperiencePlaceholderCell.h"
#import "PKTListenItemCollectionViewCell.h"
#import "PKTListenCoverFlowItemCollectionViewCell.h"
#import "PKTListenPlaylistHeaderViewCell.h"

// Section Controllers

// Controls
#import "PKTListenSpeedControl.h"

// Protocols
#import "PKTAudibleQueue.h"
#import "PKTDrawerAnimatedTransitioningDelegate.h"
#import "PKTListenItem.h"
#import "PKTListenAudibleQueuePresentationContext.h"
#import "PKTAudibleItemCache.h"
#import "PKTListenPlayer.h"

// Categories
#import "PKTItem+PKTListenItem.h"
#import "PKTKusari+PKTListen.h"
#import "PKTRemoteMedia+PKTListen.h"
#import "PKTListenCacheManager+Settings.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *_Nonnull const PKTListenLibraryVersion;

UIKIT_EXTERN NSString *_Nonnull const PKTListenAuthorsIntroductionVersion;
UIKIT_EXTERN NSString *_Nonnull const PKTListenLanguageIntroductionVersion;
UIKIT_EXTERN NSString *_Nonnull const PKTListenEstimatedListenTimeIntroductionVersion;
UIKIT_EXTERN NSString *_Nonnull const PKTListenDomainMetadataIntroductionVersion;

UIKIT_EXTERN NSString * const PKTListenAudibleItemSectionDidSelectItemNotification;

typedef NS_ENUM(NSInteger, PKTListenQueueSectionType) {
    PKTListenQueueSectionTypeUndefined,
    PKTListenQueueSectionTypePlaceholder,
    PKTListenQueueSectionTypeListenHeader,
    PKTListenQueueSectionTypeItem = 8911,
    PKTListenQueueSectionTypeListenQueue = 8912,
};

typedef NS_ENUM(NSInteger, PKTListenItemState) {
    PKTListenItemStateUndefined = 0,
    PKTListenItemStateRequestingURL,
    PKTListenItemStateReceivedURL,
    PKTListenItemStateReceivedMediaResponse,
    PKTListenItemStateStreamIsStreaming,
    PKTListenItemStateStreamFinished,
    PKTListenItemStateStreamFailed,
};
// When a stream is considered to have been "listened to"
UIKIT_EXTERN CGFloat const PKTListenCompletionProgress;
// Padding between the top of the listen drawer and the status bar.
UIKIT_EXTERN CGFloat const PKTListenDrawerStatusBarSpacing;
UIKIT_EXTERN CGFloat const PKTListenDrawerLegacyStatusBarSpacing;
// Minimum width of the collapsed control
UIKIT_EXTERN CGFloat const PKTListenSpeedControlMinimumCollapsedSpan;
// Minimum width of the expanded control
UIKIT_EXTERN CGFloat const PKTListenSpeedControlMinimumExpandedWidth;
// Default playback rate
UIKIT_EXTERN NSInteger const PKTListenDefaultPlaybackRate;
// Minimum playback rate
UIKIT_EXTERN NSInteger const PKTListenMinimumPlaybackRate;
// Maximum playback rate
UIKIT_EXTERN NSInteger const PKTListenMaximumPlaybackRate;
// Increment of playback rate
UIKIT_EXTERN NSInteger const PKTListenPlaybackRateIncrement;
// Height of the expanded control
UIKIT_EXTERN CGFloat const PKTListenSpeedControlExpandedHeight;

// Default padding and spacing for all UI elements
UIKIT_EXTERN CGFloat const PKTListenDefaultSpacingRed;
UIKIT_EXTERN CGFloat const PKTListenDefaultSpacingOrange;
UIKIT_EXTERN CGFloat const PKTListenDefaultSpacingBlue;

// Height of the download and playback progress bar
UIKIT_EXTERN CGFloat const PKTListenProgressBarVerticalSpan;
// Span of the playback progress thumb pad as drawn
UIKIT_EXTERN CGFloat const PKTListenProgressBarThumbPadSpan;
// Span of the playback progress bar's view
UIKIT_EXTERN CGFloat const PKTListenProgressBarThumbTouchSpan;

// How much additional hugging to add to the cover flow items that are not stage center (e.g., left/right)
UIKIT_EXTERN CGFloat const PKTListenCoverFlowCollectionViewLayoutHugging;
// Minimum scale transformation to apply to cover flow items that are not stage center (e.g, left/right)
UIKIT_EXTERN CGFloat const PKTListenCoverFlowMinimumScaleFactor;
// Minim alpha for the the cover flow items that are not stage center (e.g., left/right)
UIKIT_EXTERN CGFloat const PKTListenCoverFlowMinimumAlpha;

// Typefaces
UIKIT_EXTERN NSString * const PKTListenMediumWeightFontFace;
UIKIT_EXTERN NSString * const PKTListenRegularWeightFontFace;
UIKIT_EXTERN NSString * const PKTListenLetterPressFontFace;

// Messages
UIKIT_EXTERN CGFloat const PKTListenMessagingMinimumLineHeight;
UIKIT_EXTERN CGFloat const PKTListenMessagingFontSize;
UIKIT_EXTERN NSString * const PKTListenMessagingDefaultFontFace;
UIKIT_EXTERN NSString * const PKTListenMessagingWarningFontFace;

UIKIT_EXTERN CGFloat const PKTListenDefaultLineSpacing;

// Controls Container
// Height of the controls within the player view. This controls height/width of the play/pause circle.
UIKIT_EXTERN CGFloat const PKTListenControlsContainerVerticalSpan;

// Player Title Text
UIKIT_EXTERN CGFloat const PKTListenTitleTextFontSize;
UIKIT_EXTERN CGFloat const PKTListenTitleTextMinimumLineHeight;
// Value to subtract from title's baseline to bring x-height flush to parent container
UIKIT_EXTERN CGFloat const PKTListenTitleTextBaselineOffsetTop;

// Detail Text
UIKIT_EXTERN CGFloat const PKTListenDetailTextFontSize;
UIKIT_EXTERN CGFloat const PKTListenDetailTextMinimumLineHeight;

// Time Elapsed/Remaining
UIKIT_EXTERN CGFloat const PKTListenTimeControlsTextFontSize;
UIKIT_EXTERN CGFloat const PKTListenTimeControlsTextMinimumLineHeight;

// PKTItem Cells
UIKIT_EXTERN CGFloat const PKTListenItemCellTitleTextFontSize;
UIKIT_EXTERN CGFloat const PKTListenItemCellTitleTextMinimumLineHeight;

UIKIT_EXTERN CGFloat const PKTListenItemCellDetailTextFontSize;
UIKIT_EXTERN CGFloat const PKTListenItemCellDetailTextMinimumLineHeight;

// Playback Speed
UIKIT_EXTERN NSString * const PKTListenPlaybackSpeedTextFontFace;
UIKIT_EXTERN CGFloat const PKTListenPlaybackSpeedTextFontSize;
UIKIT_EXTERN CGFloat const PKTListenPlaybackSpeedTextLineHeight;

UIKIT_EXTERN CGFloat const PKTListenMinimumLineHeight;
// Height of touch area reserved for drawer handle
UIKIT_EXTERN CGFloat const PKTListenDrawerHandleReservedSpan;
// Expanded height of the player controls area
UIKIT_EXTERN CGFloat const PKTListenPlayerVerticalSpan;
// Compressed height of the player controls area
UIKIT_EXTERN CGFloat const PKTListenPlayerCompressedVerticalSpan;
// Span of Coverflow items
UIKIT_EXTERN CGFloat const PKTListenCoverFlowItemSpan;
// Horizontal padding between Coverflow items
UIKIT_EXTERN CGFloat const PKTListenCoverFlowItemHorizontalPadding;

UIKIT_EXTERN NSTimeInterval const PKTListenStreamRequestTimeOutDelay;

UIKIT_EXTERN NSInteger const PKTListenIdleTimeOutMinutes;

UIKIT_EXTERN NSTimeInterval const PKTListenCommitmentDelay;

UIKIT_EXTERN NSTimeInterval const PKTListenManuallyStagedPlaybackDelay;

UIKIT_EXTERN NSTimeInterval const PKTListenAutomaticNextAfterFailureQueueDelay;

UIKIT_EXTERN NSTimeInterval const PKTListenAutomaticNextAfterFailurePlaybackDelay;

UIKIT_EXTERN NSTimeInterval const PKTListenAutomaticNextQueueDelay;

UIKIT_EXTERN NSTimeInterval const PKTListenAutomaticNextPlaybackDelay;

// How far forward/backward we seek when the user taps the seek button
UIKIT_EXTERN NSTimeInterval const PKTListenSeekDuration;

#ifndef PKTListenConfiguration_h
#define PKTListenConfiguration_h

// Maximum cell width of the cover flow items _in their non-transformed state_.
#define PKTListenCoverFlowCellWidth ({ (PKTListenCoverFlowItemSpan + PKTListenCoverFlowItemHorizontalPadding); })

// Height of the coverflow area
#define PKTListenCoverFlowVerticalSpan ({ \
    CGFloat span = 0; \
    if (PKTListen.accessibilityModeEnabled) { \
        span = 0; \
    } \
    else { \
        span = PKTListenCoverFlowItemSpan + PKTListenTitleTextMinimumLineHeight - 9 + (PKTListenDefaultSpacingRed * 2); \
    } \
span; })

// Total height of the expanded player view, including area reserved for drawer handle, cover flow, scrubber, time, and controls
#define PKTListenExperienceVerticalSpan ({ \
    CGFloat span = 0.0f; \
    if (PKTListen.accessibilityModeEnabled) { \
        span = (PKTListenDrawerHandleReservedSpan + [PKTListen sharedInstance].accessibilityModePlayerHeight + PKTListenCoverFlowVerticalSpan); \
    } \
    else { \
        span = (PKTListenDrawerHandleReservedSpan + PKTListenPlayerVerticalSpan + PKTListenCoverFlowVerticalSpan); \
    } \
    span; \
})

// The vertical offset of the player controls area from the top of the drawer. Includes the area reserved for drawer, and the cover flow
#define PKTListenPlayerVerticalOffset ({ (PKTListenCoverFlowVerticalSpan+PKTListenDrawerHandleReservedSpan); })

#endif /* PKTListenConfiguration_h */

// PKTItem List Collection View Cells

UIKIT_EXTERN CGFloat const PKTListenItemCollectionViewCellMaxImageSpan;
UIKIT_EXTERN CGFloat const PKTListenItemCollectionViewCellMinImageSpan;
UIKIT_EXTERN CGFloat const PKTListenItemCollectionViewCellSquareImageSpan;
UIKIT_EXTERN CGFloat const PKTListenItemCollectionViewCellImagePadding;
UIKIT_EXTERN CGFloat const PKTListenItemCollectionViewDetailTopPadding;

#define PKTListenAppearanceEnabled 0

@protocol PKTUITheme;

/**
 PKTListenConfiguration describes an object container that vends configuration and dependencies necessary for the
 listen system.
 */

@protocol PKTListenConfiguration<NSObject>

/// Initial analytics context.
/// @note Analytics context definitions are extratextual
@property (nonatomic, readonly, strong, nullable) NSDictionary *context;
/// The audible item cache to be user for persisting and loading listen item metadata (e.g., stream state)
@property (nonatomic, readonly, strong, nonnull) id<PKTAudibleItemCache> cache;
/// NSDictionary of behavior that will be associated with listen button presses
@property (nonatomic, readonly, copy, nullable) NSDictionary<NSString *, dispatch_block_t> *actions;
/// The source of the audible item queue
/// @note The source is responsible for generating the list of items that will be presented in the listen list as playable
@property (nonatomic, readonly, strong, nonnull) PKTListenDataSource<id<PKTListenItem>> *source;
/// The current network connection type
/// @note This value must be KVO compliant, in order for Listen to observe changes to network connectivity
@property (nonatomic, readonly, assign) PKTNetworkConnectionType connection; // KVO Observable
/// The store to use for loading user settings.
@property (nonatomic, readonly, strong, nonnull) id<PKTListenStore> store;
/// The play type
@property (nonatomic, readwrite, assign) PKTAudibleQueueInitialPlayType playType;

- (PKTListenPlaybackType)availablePlaybackType:(PKTKusari<id<PKTListenItem>> *)kusari;

/// @return The <PKTListenPlayer> object appropriate for playback of the provided listen item, if any.
/// @param kusari a kusari wrapping the listen item to be played
/// @param queue the audible item queue from which the listen item was sourced
/// @param playerType on return, the type of listen player that was vended
/// @param error if this method returns nil, a pointer to a valid NSError describing why no player was provided

- (nullable id<PKTListenPlayer>)playerForKusari:(PKTKusari<id<PKTListenItem>> *)kusari
                                          queue:(nonnull id<PKTAudibleQueue>)queue
                                           type:(inout PKTListenPlaybackType *)playerType
                                          error:(NSError **)error;

@end

@protocol PKTListenServiceDelegate <NSObject>

@required

- (void)postAction:(NSString *)actionName
            kusari:(PKTKusari<id<PKTListenItem>> *_Nullable)kusari
              data:(NSDictionary *)userInfo;

- (void)listenDidPresentPlayer:(id<PKTListenAudibleQueuePresentationContext> _Nonnull)player;

- (void)listenDidDismissPlayer:(id<PKTListenAudibleQueuePresentationContext> _Nonnull)player;

- (void)listenDidDismiss;

- (id<PKTItemSessionService> _Nullable)itemSessionService;

@optional

- (void)listenDidCollapseIntoMiniPlayer:(id<PKTListenAudibleQueuePresentationContext> _Nonnull)listen;

- (void)listenDidCloseMiniPlayer:(id<PKTListenAudibleQueuePresentationContext> _Nonnull)listen;

- (void)listenDidExpandFromMiniPlayer:(id<PKTListenAudibleQueuePresentationContext> _Nonnull)listen;

- (id<PKTUITheme>)currentColors;

@end

@protocol PKTListenPocketProxy <NSObject>

- (void)archiveKusari:(PKTKusari<id<PKTListenItem>> *)kusari userInfo:(NSDictionary *)userInfo;

/**
 The deferred action to add a kusari with given user info to a user's list (i.e "save").
 
 @param kusari The kusari to add to a user's list
 @param userInfo Contextual information from which the kusari was added
 */
- (void)addKusari:(PKTKusari<id<PKTListenItem>> *)kusari userInfo:(NSDictionary *)userInfo;

- (void)refreshAlbum:(id<PKTListenItem>)album completion:(void (^)(id<PKTListenItem>))completion;

- (id<PKTKeyValueStore>)store;

@end

@interface PKTListen : NSObject

@property (nonatomic, readonly, assign, class) UIColor *redLayoutColor;
@property (nonatomic, readonly, assign, class) UIColor *blueLayoutColor;
@property (nonatomic, readonly, assign, class) UIColor *orangeLayoutColor;
@property (nonatomic, readonly, assign, class) UIColor *invisibleLayoutColor;

@property (nonatomic, readwrite, assign, class) BOOL visualizeLayout;
@property (nonatomic, readwrite, assign, class) BOOL experimentalLayoutsEnabled;
@property (nonatomic, readwrite, assign, class) BOOL automaticallySkipPlayedItems;
@property (nonatomic, readwrite, assign, class) BOOL accessibilityModeEnabled;

@property (nonatomic, readwrite, assign, class) NSInteger maximumWordCount;
@property (nonatomic, readwrite, assign, class) NSInteger minimumWordCount;

@property (nonnull, nonatomic, readonly, class) UIFont *listCellTitleFont;
@property (nonnull, nonatomic, readonly, class) UIFont *listCellSubtitleFont;
@property (nonnull, nonatomic, readonly, class) UIFont *playlistHeaderFont;
@property (nonnull, nonatomic, readonly, class) UIFont *playerTitleFont;
@property (nonnull, nonatomic, readonly, class) UIFont *playerSubtitleFont;
@property (nonnull, nonatomic, readonly, class) UIFont *playerTimeTrackingFont;
@property (nonnull, nonatomic, readonly, class) UIFont *abstractMessageFont;
@property (nonnull, nonatomic, readonly, class) UIFont *warningMessageFont;
@property (nonnull, nonatomic, readonly, class) UIFont *speedControlFont;
@property (nonnull, nonatomic, readonly, class) UIFont *playerSourceFont;
@property (nonnull, nonatomic, readonly, class) UIFont *playerSourceBoldFont;
@property (nonnull, nonatomic, readonly, class) UIFont *letterPressFont;

@property (nonatomic, readwrite, assign) CGFloat accessibilityModePlayerHeight;

@property (nullable, nonatomic, readwrite, strong, class) NSSet<NSString*> *supportedLanguages;
@property (nullable, nonatomic, readwrite, strong, class) NSSet<NSString*> *supportedMediaTypes;

@property (nonatomic, readwrite, assign, class) BOOL itemFilterDisabled;
@property (nonatomic, readwrite, assign, class) BOOL visualizeFailedImageDownloads;
@property (nonatomic, readwrite, assign, class) NSTimeInterval maximumListeningSessionDuration;
@property (nonnull, nonatomic, readwrite, class, copy) BOOL (^itemFilter)(id<PKTListenItem> anItem);
@property (nonnull, nonatomic, readwrite, class, copy) BOOL (^itemFilterRelaxed)(id<PKTListenItem> anItem);

@property (nullable, nonatomic, readwrite, weak) id<PKTListenServiceDelegate> sessionDelegate;
@property (nullable, nonatomic, readwrite, weak) id<PKTListenPocketProxy> pocketProxy;

@property (nullable, nonatomic, readonly, strong) id<PKTAudibleQueue> audibleQueue; // KVO Observable
@property (nullable, nonatomic, readonly, weak) PKTKusari<id<PKTListenItem>> *staged; // KVO Observable
@property (nullable, nonatomic, readonly, strong) PKTListenSession *session;

@property (nullable, nonatomic, readonly, weak, class) id<PKTUITheme> currentColors;

@property (nonnull, nonatomic, readonly, copy) id<PKTListenItem>_Nullable (^filter)(id<PKTListenItem> _Nonnull);

+ (instancetype)sharedInstance;

+ (void)reset;

- (void)loadDefaults;

- (void)startSession:(id<PKTAudibleQueue> _Nullable)audibleQueue;

- (void)stopSession:(id<PKTAudibleQueue> _Nullable)audibleQueue;

- (void)ding;

+ (void)updateSettings;


#pragma mark - Audio Session

- (void)startAudioSession;

- (void)stopAudioSession;

#pragma mark - Notifying Listen of Presentation

- (void)didPresentPlayer:(id<PKTListenAudibleQueuePresentationContext>)player;

- (void)didDismissPlayer:(id<PKTListenAudibleQueuePresentationContext>)player;

- (void)didDismiss;

#pragma mark - Factory

+ (id<PKTAudibleQueue>)queueWithConfiguration:(id<PKTListenConfiguration>)configuration;

#pragma mark PKTListen+PKTListenPocketProxy

- (void)postAction:(NSString *)actionName
            kusari:(PKTKusari<id<PKTListenItem>>*_Nullable)kusari
              context:(NSDictionary *_Nullable)userInfo;

- (void)archiveKusari:(PKTKusari<id<PKTListenItem>> *)kusari userInfo:(NSDictionary *)userInfo;

/**
 The action to add a kusari with given user info to a user's list (i.e "save").
 Calling this method will defer the action to the proxy.
 
 @param kusari The kusari to add to a user's list
 @param userInfo Contextual information from which the kusari was added
 */
- (void)addKusari:(PKTKusari<id<PKTListenItem>> *)kusari userInfo:(NSDictionary *)userInfo;

- (id<PKTItemSessionService> _Nullable)itemSessionService;

#pragma mark - Helpers

- (void)refreshAlbum:(id<PKTListenItem>)album completion:(void (^)(id<PKTListenItem>))completion;

#pragma mark - Utilities

NSString * MPMusicPlaybackStateDescription(MPMusicPlaybackState state);

@end

@interface UIViewController (PKTListen)

@property (nullable, nonatomic, readonly) NSString *recursiveTitle;

@end

@interface PKTListen (PKTListenEphemeralMessaging)

+ (void)pushMessage:(NSString *_Nonnull)message;

+ (void)pushWarning:(NSString *_Nonnull)warning;

+ (void)pushError:(NSError *_Nonnull)error;

@end

NS_ASSUME_NONNULL_END
