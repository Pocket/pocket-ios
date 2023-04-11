/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Basic demonstration of how to use the SystemConfiguration Reachablity APIs.
 */

@import Foundation;
@import SystemConfiguration;
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSInteger {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;

typedef NS_OPTIONS(int64_t, PKTNetworkConnectionType) {
    PKTNetworkConnectionTypeUndefined   = 0 << 0,
    PKTNetworkConnectionTypeNone        = 1 << 1,
    PKTNetworkConnectionTypeUnknown     = 1 << 2,
    PKTNetworkConnectionTypeWiFi        = 1 << 3,
    PKTNetworkConnectionTypeCellular    = 1 << 4,
    PKTNetworkConnectionType2G          = 1 << 5,
    PKTNetworkConnectionType3G          = 1 << 6,
    PKTNetworkConnectionTypeLTE         = 1 << 7,
};

UIKIT_EXTERN NSString * const kReachabilityChangedNotification;

@interface Reachability : NSObject

/*!
 * Use to check the reachability of a given host name.
 */
+ (nullable instancetype)reachabilityWithHostName:(NSString *)hostName;

/*!
 * Use to check the reachability of a given IP address.
 */
+ (nullable instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/*!
 * Checks whether the default route is available. Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;

/*!
 * Checks whether a local WiFi connection is available.
 */
+ (instancetype)reachabilityForLocalWiFi;

/*!
 * Start listening for reachability notifications on the current run loop.
 */
- (BOOL)startNotifier;
- (void)stopNotifier;

- (NetworkStatus)currentReachabilityStatus;

/*!
 * WWAN may be available, but not active until a connection has been established. WiFi may require a connection for VPN on Demand.
 */
- (BOOL)connectionRequired;

+ (PKTNetworkConnectionType)connectionType:(NSString *)hostName;

- (PKTNetworkConnectionType)connectionType;

NSString *_Nullable PKTNetworkConnectionTypeDescription(PKTNetworkConnectionType type);

@end

NS_ASSUME_NONNULL_END

