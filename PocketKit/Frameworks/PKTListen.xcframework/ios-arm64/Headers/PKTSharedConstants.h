//
//  PKTSharedConstants.h
//  RIL
//
//  Created by Michael Schneider on 7/8/15.
//
//

#import <Foundation/Foundation.h>

#pragma mark - Notifications

extern NSString * const PKTSCListRefreshErrorNotification;
extern NSString * const PKTSCListRefreshCancelledNotification;
extern NSString * const PKTSCListRefreshOfflineErrorNotification;
extern NSString * const PKTSCListNeedsRefreshNotification;
extern NSString * const PKTSCItemAssignedUniqueIdNotification;
extern NSString * const PKTSCItemsNeedRefreshFromSyncNotification;
extern NSString * const PKTSCItemIsDoneNotification;
extern NSString * const PKTSCItemExtendedUpdatedNotification;
extern NSString * const PKTSCAccountInformationChangedNotification;
extern NSString * const PKTSCOfflineSyncStatusChangedNotification;
extern NSString * const PKTSCFetchingStatusChangedNotification;
extern NSString * const PKTSCSendDidFinishNotification;
extern NSString * const PKTSCRefreshCarouselNotification;
extern NSString * const PKTSCCacheWasClearedNotification;
extern NSString * const PKTSCTextURLIsDoneNotification;
extern NSString * const PKTSCOfflineWasCancelledNotification;
extern NSString * const PKTSCImageInfoFetchedNotification;
extern NSString * const PKTSCWaitingForThumbnailSourceDownloadNotification;
UIKIT_EXTERN NSString * const PKTRemoteItemDidUpdateNotification;

#pragma mark - User Defaults

extern NSString * const PKTSCNotificationStatusChangedNotificationKey;

#pragma mark - Keychain

#define RILGlobalKeychainServiceName @"Pocket"
