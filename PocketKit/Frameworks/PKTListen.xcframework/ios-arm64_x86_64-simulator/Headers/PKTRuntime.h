//
//  PKTRuntime.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 1/19/17.
//  Copyright © 2017 Pocket. All rights reserved.
//

@import UIKit;

#pragma mark -

#import "PKTSharedEnums.h"
#import "PKTSharedConstants.h"
#import "PKTShare.h"
#import "PKTSessionManager.h"
#import "PKTRecentPeopleManager.h"
#import "PKTNetworkReachabilityManager.h"
#import "PKTJSON.h"
#import "PKTiOSConstants.h"
#import "PKTHandyMacros.h"
#import "PKTFunctions.h"
#import "PKTFriendsCache.h"
#import "PKTFriend.h"
#import "PKTContact.h"
#import "PKTPerson.h"
#import "PKTNotification.h"
#import "PKTFeedItemPost.h"
#import "PKTPosition.h"
#import "PKTExtendedAttribution.h"
#import "PKTUser.h"
#import "PKTUserProfileProtocol.h"
#import "PKTSettingsHelperFunctions.h"
#import "PKTiOSEnums.h"
#import "PKTExtendedAttributionTypesManager.h"
#import "PKTUserProfile.h"
#import "PKTFeedItemPost.h"
#import "PKTDebugTimer.h"
#import "PKTKeyValueStore.h"
#import "PKTUserEventStore.h"
#import "PKTFileObserver.h"
#import "PKTJSONParser.h"
#import "PKTJSONDAO.h"
#import "PKTFeature.h"
#import "PKTMigration.h"

// Models

#import "PKTItem.h"
#import "PKTKusari.h"
#import "PKTDomainMetadata.h"

// Networking

#import "NSURLSessionTask+PKTAdditions.h"
#import "PKTDataTask.h"
#import "PKTURLSessionManager.h"
#import "PKTURLSessionTaskBucket.h"
#import "PKTMultipartFormData.h"
#import "APIRequestGate.h"
#import "PKTAPIRequest.h"
#import "RILGUID.h"
#import "PKTAPIRequestBuild.h"
#import "PKTRemoteMedia.h"
#import "PKTActionTrace.h"

// Non-namespaced Classes
#import "TransactionDataOperation.h"
#import "SyncRemoteProcessOperation.h"
#import "Reachability.h"
#import "ListDataOperation.h"
#import "PKTItem.h"
#import "GetListOperation.h"
#import "GetItemOperation.h"
#import "DataOperationQueue.h"
#import "DataOperation.h"
#import "Action.h"
#import "AssetManager.h"
#import "Asset.h"
#import "AppAsset.h"

// Backports
#import "PKTBackports.h"
#import "UIScreen+PKTBackports.h"

// Vendor
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "GTMNSString+HTML.h"
#import "SFHFKeychainUtils.h"
#import "KCDRemoteMedia.h"

// Categories
#import "NSLayoutConstraint+PKTAdditions.h"
#import "UIGestureRecognizer+PKTAdditions.h"
#import "NSURL+PocketAdditions.h"
#import "NSString+PocketAdditions.h"
#import "NSFileManager+PocketAdditions.h"
#import "NSDictionary+PocketAdditions.h"
#import "NSDate+PocketAdditions.h"
#import "NSData+PocketAdditions.h"
#import "NSArray+PocketAdditions.h"
#import "NSError+PKTAdditions.h"
#import "NSThread+PKTAdditions.h"
#import "FMResultSet+PKTAdditions.h"
#import "FMDatabase+PKTAdditions.h"
#import "UIColor+PKTAdditions.h"
#import "UIView+PKTPathParsing.h"
#import "PKTAppearanceExpression.h"
#import "Item+PKTListDiffable.h"
#import "UIControl+PKTAdditions.h"
#import "PKTRemoteMedia+FileURLs.h"
#import "Item+PKTImageResource.h"
#import "PKTJSONParser+PKTTransformations.h"
#import "UIImage+PKTLetterPress.h"
#import "UIApplication+PKTContentSizeCategory.h"
#import "NSNumber+PKTAdditions.h"
#import "NSCountedSet+PKTAdditions.h"

// Protocols
#import "PKTThemeProtocol.h"
#import "PKTImageResource.h"
#import "PKTImageCacheManagement.h"
#import "PKTUITheme.h"
#import "PKTContextAnalyticsProtocol.h"

// Utilities
#import "PKTAppearanceMask.h"
#import "PKTGeometry.h"

// Views
#import "PKTRenderView.h"
#import "PKTFPSLabel.h"

// Encryption
#import "PKTCryptor.h"
#import "PKTKeyGenerator.h"

// Helpers
#define BUNDLE_NAME       @"PKTListenResources.bundle"
#define BUNDLE_IDENTIFIER @"com.ReadItLaterPro.PKTListenResources"
#define BUNDLE_PATH       [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: BUNDLE_NAME]
#define PKTListenResourceBundle [NSBundle bundleWithPath: BUNDLE_PATH]

NS_ASSUME_NONNULL_BEGIN;

UIKIT_EXTERN NSString *__nonnull const PKTShareExtensionAPICommunicatorBaseURL;
UIKIT_EXTERN NSString *__nonnull const PKTShareExtensionAPICommunicatorBackgroundTaskIdentifier;
UIKIT_EXTERN NSString *__nonnull const PKTSharedKeychainGroupName;
UIKIT_EXTERN NSString *__nonnull const kPKTLogTagInfoLogZone;
UIKIT_EXTERN NSString *__nonnull const kPKTLogTagInfoClassName;
UIKIT_EXTERN NSString *__nonnull const kPKTLogTagInfoSelectorName;

@interface PKTRuntime : NSObject

@end

NS_ASSUME_NONNULL_END;
