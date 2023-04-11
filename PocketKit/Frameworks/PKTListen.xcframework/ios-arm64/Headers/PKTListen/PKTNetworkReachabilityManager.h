//
//  PKTNetworkReachabilityManager.h
//  RIL
//
//  Created by Michael Schneider on 6/24/14.
//
//

@import UIKit;

#import "PKTiOSEnums.h"
#import "Reachability.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const PKTNetworkReachabilityDidChangeNotification;

typedef NS_ENUM(NSInteger, PKTNetworkConnectionQuality) {
    PKTNetworkConnectionQualityNone,
    PKTNetworkConnectionQualityLow,
    PKTNetworkConnectionQualityNormal,
    PKTNetworkConnectionQualityHigh,
    PKTNetworkConnectionQualityVeryHigh,
};

@interface PKTNetworkReachabilityManager : NSObject

/// Helper method to check if given error is a network error
+ (BOOL)errorIsNetworkError:(NSError *)error;

/// Returns the shared network reachability manager.
+ (instancetype)sharedManager;

/// Returns a new instance with the provided reachability
+ (instancetype)networkReachability:(Reachability *)reachability name:(NSString *)name;

/// The quality of the network connection, as derived from the connection type.
@property (readonly, atomic, assign) PKTNetworkConnectionQuality quality;

/// The connection technology type
@property (readonly, atomic, assign) PKTNetworkConnectionType connectionType; // KVO observable

/// The current network reachability status.
@property (readonly, nonatomic, assign) PKTNetworkStatus networkReachabilityStatus; // KVO observable

/// Whether or not the network is currently reachable.
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/// Whether or not the network is currently reachable via WWAN.
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/// Whether or not the network is currently reachable via WiFi.
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

/// Returns the name of this manager
@property (readonly, nonatomic, copy, nullable) NSString *name;

- (void)startMonitoring;
- (void)stopMonitoring;
- (BOOL)hostIsReachable:(NSString *)host;

+ (PKTNetworkConnectionQuality)quality:(NSString *)hostName;

PKTNetworkConnectionQuality PKTNetworkQualityForConnectionType(PKTNetworkConnectionType type);

@end

NS_ASSUME_NONNULL_END
