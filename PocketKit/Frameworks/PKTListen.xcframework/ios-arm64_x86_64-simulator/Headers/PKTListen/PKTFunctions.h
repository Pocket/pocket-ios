//
//  Functions.h
//  RIL
//
//  Created by Nathan Weiner on 11/5/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

@import Foundation;
@import UIKit;

#import "PKTSharedEnums.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTItem;
@class PKTAppDelegate;

/// Current app version (CFBundleShortVersionString)
NSString *version(void);

/// Return the preferred locale for the app by using the preferredLocalizations method on the NSBundle object
NSString *preferredLocale(void);

/// Create locale identifier in Format: e.g. en-US. Used for sending locale with APIRequest and support alert views
NSString *localeString(void);

/// Convert the preferred locale from iOS to the locale we use on our Backend. We use that for getting the groups
NSString *preferredLocaleIdentifier(void);

/// Returns the Minutes from GMT as string
NSString *timeZoneString(void);

/// Converts an int to NSString
NSString * i2s( int n );

/// Converts an int to NSNumber
NSNumber * i2n( int n );

/// Converts and NSInteger to NSNumber
NSNumber * nsint2n( NSInteger n );

/// Converts a double to NSString
NSString * d2s( double n );

/// Converts a bool to NSString
NSString * b2s( BOOL b );

/// Empty string if null (a quick way to prevent nulls from breaking sql)
id eifn( id val );

/// NSNull if null
id nifn( id val);

/// 
double PKTRetinaRound(double val);

/// Check if given URL string is a valid url
BOOL isValidURLStr(NSString * urlStr);

/// Check if given NSURL is a valid URL
BOOL isValidURL(NSURL * url);

/// The function expects a tag that is already whitespace trimmed
BOOL isValidTag(NSString *tag);

/// Return new string to be use in urls from given string
NSString *urlEncode(NSString *urlStr);

/// Return new string to be encoded from urls from given string
NSString *urlDecode(NSString *urlStr);

/// Because we cannot send any utf encoded messages within the headers we have to decode the error message sent from the server
NSString *xErrorHeaderUnescape(NSString *xError);

/// Encode the given string for usage in JavaScript
NSString *javascriptEncode(NSString *string);

/// Encode the given string for usage in JavaScript
NSString *javascriptEncodeAdvanced(NSString *string, BOOL isJSON);

/// Create redirect URL's for urls
NSString * PKTRedirectURLStringForURL(NSURL *url);

/// Wraps given URL in a Pocket Referrer URL string and returns this
NSString *PKTReferrerForURL(NSURL * url);

/// Returns referrer for recommendations
NSString *PKTReferrerForRecommendations(void);

/// Returns the given_{key} or resolved_{key} based on which exists property from the given item
NSString *givenOrResolved(NSDictionary *item, NSString *key) NS_DEPRECATED_IPHONE(2.0, 10.0); // "Use PKTResolvedOrGiven instead."

/// Returns the {key}, resolved_{key} or given_{key} based on which exists property from the given item
NSString *__nullable PKTResolvedOrGiven(NSDictionary *userInfo, NSString *key);

#pragma mark - 

/// Current user agent string
NSString * userAgent(void);

/// Supply a list of arguments, it'll pick the first one that is not nil. Must be nil-terminated.
#define RILAny(...) _RILAny(__VA_ARGS__, [NSNull null], nil)
id _Nullable _RILAny(id _Nullable firstObject, ...); // private

#pragma mark -

/// Return md5 value of given string
NSString *md5(NSString *str);

/// Return sha256 value of given string
NSString *sha256( NSString *str );

/// Returns the localized parameters string for usage within an NSURL
NSString *localParams(void);

/// Helper class for swizzling
void PKTSwizzle(Class c, SEL orig, SEL new);

/// Check if given object is not nil or NSNull
BOOL notNull(id o);

/// Because isEqualToString will return true if the base string is null, we need some better checks
BOOL stringsAreEqual(NSString *str1, NSString *str2);

#pragma mark -

/// Returns an actionId from the given name. The name comes from the frontend and the actionId is the same action just identified in the backend
ActionId actionIdForName(NSString *name);

NSString *_Nullable actionName(NSInteger actionID);

#pragma mark -

/// Creates a CGRect from a given dictionary that has NSNumber values with x, y, width and height keys
CGRect rectFromDictionary(NSDictionary *dict);

/// Creates a CGSize from a given dictionary that has NSNumber values with width and height keys
CGSize sizeFromDictionary(NSDictionary *dict);

#pragma mark -

NSString * __attribute__((overloadable)) PKTProcessTemplates(NSString *_Nullable string, NSDictionary *options);
NSString * __attribute__((overloadable)) PKTProcessTemplates(NSString *_Nullable string);

#pragma mark - 

/// Returns the current screen scale based on the platform
CGFloat screenScale(void);

#pragma mark -

/// Returns if the given NSURL is an app store URL
BOOL isAppStoreURL(NSURL *url);

/// Returns if the given NSURL is an publisher message URL
BOOL isPublisherMessageURL(NSURL *url);

#pragma mark - 

#if PKTTargetIsMac
NSString *modelIdentifierMac(void);
NSString *osVersionMac(void);
#endif

#pragma mark -

int gcf(int a, int b);
int lcm(int a, int b);
int lcmWithLowerBound(int a, int b, int min);

/// RILWebFunction block
typedef void (^RILWebFunction)(NSArray *arguments);

/// RILWebReceiver block
typedef void (^RILWebReceiver)(NSString *response);

/// Send a notification for the
void postWebNotification(NSString *name, NSString *__nullable target, NSDictionary *object);

/// Returns if the current device is known as fast
BOOL isFast(void);

/// Return nil if given object is NSNull else return the given object
id _Nullable unNSNull(id obj);

/**
 @return NSComparisonResult of comparing two application version number strings.
 */

NSComparisonResult PKTCompareVersionStrings(NSString *__nonnull v1, NSString *__nonnull v2);

BOOL clearWayToPath(NSString *path);

/**
 @return YES if the selector is defined within the provided protocol.
 */

BOOL PKTProtocolIncludesSelector(Protocol *aProtocol, SEL aSelector);

/**
 @return The primary shared container identifier for this application scope.
 */

NSString *PKTPrimarySharedContainerIdentifier(void);

/**
 @return The URL for the shared container for this application scope.
 */

NSURL *PKTPrimarySharedContainerURL(void);

typedef NS_ENUM(NSInteger, PKTDispatchMode) {
    PKTDispatchModeSync = 0,
    PKTDispatchModeAsyncMaybe,
    PKTDispatchModeAsyncAlways,
};

/**
 Dispatches a block on the main thread.
 @enum mode 1. PKTDispatchModeSync: if dispatched on the main thread, the block will be invoked immediately; if dispatched off of the main thread, the block will be dispatch synchronously to the main thread. 2. PKTDispatchModeAsyncMaybe: if dispatched on the main thread, the block will be invoked immediately; if dispatched off of the main thread, the block will be dispatch asynchronously to the main thread. 3. PKTDispatchModeAsyncAlways: if dispatched on the main thread, the block will be disatched asynchrnously; if dispatched off of the main thread, the block will be dispatch asynchronously to the main thread.
 */

void PKTDispatchMain(enum PKTDispatchMode mode, dispatch_block_t block);

#pragma mark - KVO

void PKTStartChangeObservation(id observer, id observed, void *context, SEL firstSelector,...);

void PKTStartObservation(id observer, id observed, void *context, NSKeyValueObservingOptions options, SEL aSelector,... );

void PKTStopObservation(id obserer, id observed, void *context, SEL firstSelector, ...);

#pragma mark - UIKit

typedef NS_OPTIONS(NSInteger, PKTEdges) {
    PKTEdgesNone = 0 << 0,
    PKTEdgesTop = 1 << 0,
    PKTEdgesLeft = 1 << 1,
    PKTEdgesBottom = 1 << 2,
    PKTEdgesRight = 1 << 3,
    PKTEdgesAll = 1 << 4,
};

/**
 Extend UIEdgeInsets by the insets of another UIEdgeInsets struct.
 */

UIEdgeInsets PKTEdgeInsetsExtend(UIEdgeInsets insets, UIEdgeInsets extension, PKTEdges edges);

/**
 Return a CGRect value with its edges inset by the values of the UIEdgeInsets argument.
 */

CGRect PKTRectInsetEdges(CGRect rect, UIEdgeInsets insets);

#pragma mark - Type Descriptions

/**
 Return the NSString representation of a RILViewType.
 */

NSString *_Nonnull PKTViewTypeDescription(RILViewType type);

#pragma mark - Assertions

/**
 Enumerate over provided keys and invoke NSAssert on each to validate membership within provided dictionary.
 @note In non-debug builds, missing keys will be logged as errors; no exception will be thrown.
 */

void PKTAssertKeys(NSDictionary *userInfo, NSString *key, ...) NS_REQUIRES_NIL_TERMINATION;

NS_ASSUME_NONNULL_END
