//
//  PKTCoreLogging.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 3/14/17.
//  Copyright © 2017 Pocket. All rights reserved.
//

@import UIKit;
#import "PKTKeyValueStore.h"
#import "NSDictionary+PocketAdditions.h"
#import "PKTImageCacheManagement.h"
#import "PKTCryptor.h"
#import "PKTKeyGenerator.h"

#ifndef PKTCoreLogging_h
#define PKTCoreLogging_h
#endif /* PKTCoreLogging_h */

#define NSLoggerAvailable
#define CocoaLumberjackAvailable

UIKIT_EXTERN NSString *__nonnull const PKTShareExtensionAPICommunicatorBaseURL;
UIKIT_EXTERN NSString *__nonnull const PKTShareExtensionAPICommunicatorBackgroundTaskIdentifier;
UIKIT_EXTERN NSString *__nonnull const PKTSharedKeychainGroupName;
UIKIT_EXTERN NSString *__nonnull const kPKTLogTagInfoLogZone;
UIKIT_EXTERN NSString *__nonnull const kPKTLogTagInfoClassName;
UIKIT_EXTERN NSString *__nonnull const kPKTLogTagInfoSelectorName;

#define POCKET_API_DOMAIN ({ @"getpocket.com"; })

#define PKTRuntimeIsHostApplication ({ \
_Pragma("pragma clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
NSString *bundleIdentifer = PKTCastedValueForKey([[NSBundle mainBundle] infoDictionary], (__bridge_transfer NSString *)kCFBundleIdentifierKey, NSString); \
([bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterPro"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterProAlphaNeue"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterProEnterprise"]); \
_Pragma("pragma clang diagnostic pop") \
})

#define PKTVersionIsProduction ({ \
_Pragma("pragma clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
NSString *bundleIdentifer = PKTCastedValueForKey([[NSBundle mainBundle] infoDictionary], (__bridge_transfer NSString *)kCFBundleIdentifierKey, NSString); \
([bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterPro"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterPro.AddToPocketExtension"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterPro.PocketTodayExtension"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterPro.iMessageExtension"]); \
_Pragma("pragma clang diagnostic pop") \
})

#define PKTVersionIsAlpha ({ \
_Pragma("pragma clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
NSString *bundleIdentifer = PKTCastedValueForKey([[NSBundle mainBundle] infoDictionary], (__bridge_transfer NSString *)kCFBundleIdentifierKey, NSString); \
([bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterProAlphaNeue"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterProAlphaNeue.AddToPocketExtension"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterProAlphaNeue.PocketTodayExtension"] \
|| [bundleIdentifer isEqualToString:@"com.ideashower.ReadItLaterProAlphaNeue.iMessageExtension"]); \
_Pragma("pragma clang diagnostic pop") \
})

#define PKTTestFlightEnvironment ({ \
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL]; \
    NSString *receiptURLString = [receiptURL path]; \
    BOOL isTestFlight =  ([receiptURLString rangeOfString:@"sandboxreceipt" options:NSCaseInsensitiveSearch].location != NSNotFound); \
    if (PKTVersionIsAlpha || PKTVersionIsDebug) { isTestFlight = NO; } \
    isTestFlight; \
})

#define PKTApplauseBranch ({ [PKTBuildBranchName().lowercaseString isEqualToString:@"release/applause"]; })

#define PKTBetaEnvironment ({ (PKTTestFlightEnvironment || PKTApplauseBranch); })

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#if defined DEBUG
#define PKTVersionIsDebug (YES)
#else
#define PKTVersionIsDebug (NO)
#endif

#import "PKTConsoleLogFormatter.h"
#import "PKTApplicationLogFormatter.h"
#import "PKTStreamLogger.h"

#if defined CocoaLumberjackAvailable
#import "CocoaLumberjack/CocoaLumberjack.h"
#import "CocoaLumberjack/DDContextFilterLogFormatter.h"
#import "PKTConsoleLogFormatter.h"
#import "PKTApplicationLogFormatter.h"
#import "PKTStreamLogger.h"
#import "CocoaLumberjack/DDLog.h"
#endif

#if defined NSLoggerAvailable
#import "NSLogger/LoggerCommon.h"
#import "NSLogger/LoggerClient.h"
#endif

#pragma mark - Logging

#define DATASTORE_CONTEXT                   (1 << 0)
#define UI_CONTEXT                          (1 << 1)
#define PUSH_NOTIFICATIONS_CONTEXT          (1 << 2)
#define DATAMODEL_CONTEXT                   (1 << 3)
#define AUTHENTICATION_CONTEXT              (1 << 4)
#define DAO_CONTEXT                         (1 << 5)
#define DEVICE_CONTEXT                      (1 << 6)
#define PAYMENT_CONTEXT                     (1 << 7)
#define ANALYTICS_CONTEXT                   (1 << 8)
#define APPLICATION_CONTEXT                 (1 << 9)
#define SYNC_CONTEXT                        (1 << 10)
#define NETWORK_CONTEXT                     (1 << 11)
#define RUNTIME_CONTEXT                     (1 << 12)
#define WEB_CONTEXT                         (1 << 13)
#define EXTENSION_CONTEXT                   (1 << 14)
#define SHARE_EXTENSION_CONTEXT             (1 << 15)
#define TODAY_EXTENSION_CONTEXT             (1 << 16)
#define MESSAGE_EXTENSION_CONTEXT           (1 << 17)
#define FLUX_MESSAGING_CONTEXT              (1 << 18)
#define DATABASE_CONTEXT                    (1 << 19)
#define LISTEN_CONTEXT                      (1 << 20)

#if defined CocoaLumberjackAvailable

// CocoaLumberjack configuration and macros.

#define LOG_FLAG_ERROR   DDLogFlagError
#define LOG_FLAG_WARN    DDLogFlagWarning
#define LOG_FLAG_INFO    DDLogFlagInfo
#define LOG_FLAG_DEBUG   DDLogFlagDebug
#define LOG_FLAG_VERBOSE DDLogFlagVerbose

// Set the maximum log level to be logged.
static const NSInteger ddLogLevel = DDLogLevelVerbose;

typedef NS_OPTIONS(NSUInteger, PKTLogZone) {
    PKTLogZoneNone          = 0,
    PKTLogZoneConsole       = 1 << 0,
    PKTLogZoneStream        = 1 << 1,
    PKTLogZoneDisk          = 1 << 2,
    PKTLogZoneDefault           = (PKTLogZoneConsole)
//#if defined DEBUG
//    PKTLogZoneDefault           = (PKTLogZoneConsole|PKTLogZoneDisk|PKTLogZoneStream)
//#else
 //   PKTLogZoneDefault           = (PKTLogZoneDisk|PKTLogZoneStream) // Disconnect the console log client in production.
//#endif
};

#define PKTLogZoneDynamic ({ \
_Pragma("pragma clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
    PKTLogZone zone = PKTLogZoneDefault; \
    zone; \
_Pragma("pragma clang diagnostic pop") \
})

#define PKTLogAsynchronous(flg) ((flg & LOG_FLAG_ERROR) != LOG_FLAG_ERROR)

#define LOG_TAG_MAYBE(async, lvl, flg, ctx, tag, fnct, frmt, ...) \
do { if(lvl & flg) LOG_MACRO(async, lvl, flg, ctx, tag, fnct, frmt, ##__VA_ARGS__); } while(0)

#define LOG_OBJC_TAG_MAYBE(async, lvl, flg, ctx, tag, frmt, ...) \
LOG_TAG_MAYBE(async, lvl, flg, ctx, tag, sel_getName(_cmd), frmt, ##__VA_ARGS__)

#define LOG_C_TAG_MACRO(async, lvl, flg, ctx, tag, frmt, ...) \
LOG_MACRO(async, lvl, flg, ctx, tag, __FUNCTION__, frmt, ##__VA_ARGS__)

#define PKTLoggingTag(x) ({ @{}.added(kPKTLogTagInfoClassName, NSStringFromClass([self class])).added(kPKTLogTagInfoSelectorName, NSStringFromSelector(_cmd)).added(kPKTLogTagInfoLogZone, @(x)); })
#define PKTSparseLoggingTag(x) (@{ kPKTLogTagInfoLogZone : @(x) })
#define PKTLoggingTagCMacro(x, c, s) (@{ kPKTLogTagInfoClassName : c, kPKTLogTagInfoSelectorName : s, kPKTLogTagInfoLogZone : @(x), })

// Primary logging macro. Invocation, e.g., PKTLog(PKTLogZoneConsole, APPLICATION_CONTEXT, LOG_FLAG_DEBUG, @"This is a statement about %@", aThing);

#define PKTLog(zone, ctx, flg, frmt, ...)  LOG_OBJC_TAG_MAYBE(PKTLogAsynchronous(flg), ddLogLevel, flg, ctx, PKTLoggingTag(zone), frmt, ##__VA_ARGS__)
#define PKTCLog(zone, ctx, flg, frmt, ...)  LOG_C_TAG_MACRO(PKTLogAsynchronous(flg), ddLogLevel, flg, ctx, PKTSparseLoggingTag(zone), frmt, ##__VA_ARGS__)
#define PKTLogInline(zone, ctx, flg, frmt, ...)  LOG_OBJC_TAG_MAYBE(NO, ddLogLevel, flg, ctx, PKTLoggingTag(zone), frmt, ##__VA_ARGS__)

// Function-based equivalent to PKTLog that permits logging from C functions.
#define PKTLogF(zone, ctx, flg, frmt, ...)  LOG_C_TAG_MACRO(PKTLogAsynchronous(flg), ddLogLevel, flg, ctx, frmt, ##__VA_ARGS__)
#else

// CocoaLumberjack is not available, default to standard logging.

#define PKTLog(zone, ctx, flg, frmt, ...)  NSLog(@"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(frmt), ##__VA_ARGS__] )

#endif

// Log macros that will automatically collect context information from the Objective-C Runtime.

#define DLog(s, ... ) ({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
PKTLog(PKTLogZoneDynamic, APPLICATION_CONTEXT, LOG_FLAG_DEBUG, @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__]); \
_Pragma("clang diagnostic pop") \
})

#define ALog(s, ... ) ({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
PKTLog((PKTLogZoneConsole|PKTLogZoneStream|PKTLogZoneDisk), APPLICATION_CONTEXT, LOG_FLAG_INFO, @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__]); \
_Pragma("clang diagnostic pop") \
})

#define ELog(s, ... ) ({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
PKTLog((PKTLogZoneConsole|PKTLogZoneStream|PKTLogZoneDisk), APPLICATION_CONTEXT, LOG_FLAG_ERROR, @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__]); \
_Pragma("clang diagnostic pop") \
})

// Log macros that can be used to generate contextual log lines from C functions.

#define DLogF(s, ... ) ({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
PKTLogF(PKTLogZoneDynamic, APPLICATION_CONTEXT, LOG_FLAG_DEBUG, @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__]); \
_Pragma("clang diagnostic pop") \
})

#define ALogF(s, ... ) ({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
PKTLogF((PKTLogZoneConsole|PKTLogZoneStream|PKTLogZoneDisk), APPLICATION_CONTEXT, LOG_FLAG_INFO, @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__]); \
_Pragma("clang diagnostic pop") \
})

#define ELogF(s, ... ) ({ \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-bridge-casts-disallowed-in-nonarc\"") \
PKTLogF((PKTLogZoneConsole|PKTLogZoneStream|PKTLogZoneDisk), APPLICATION_CONTEXT, LOG_FLAG_ERROR, @"%@", [NSString stringWithFormat:(s), ##__VA_ARGS__]); \
_Pragma("clang diagnostic pop") \
})

// Asserts


/** [POCKET-6528] 2017.03.21 We really need to disable NSAssert in production. I'm not how this confusion began, but we
 have dependencies that use NSAssert, and they are not going to opt into our strangeness. Until then, PKTAssert
 delivers on the promise made by its predecessor:
 
 If asserts happen in Debug Mode it will throw the assertion. In production it will just print out the error
 
 PKTAssertF is compatible with C functions and Objective-C static blocks.
 
 */

#define PKTAssert(condition, ...) do { \
    if (isDebuggerAttached()) { \
        if (!(condition)) { \
            NSLog(__VA_ARGS__); \
        } \
        NSAssert(condition, __VA_ARGS__); \
    } else if (!(condition)) { \
        NSLog(__VA_ARGS__); \
        PKTLog(PKTLogZoneDynamic, APPLICATION_CONTEXT, LOG_FLAG_ERROR, __VA_ARGS__); \
    } \
} while (0)

#define PKTAssertF(condition, ...) do { \
    if (isDebuggerAttached()) { \
        if (!(condition)) { \
            NSLog(__VA_ARGS__); \
        } \
        NSCAssert(condition, __VA_ARGS__); \
    } else if (!(condition)) { \
        NSLog(__VA_ARGS__); \
        PKTCLog(PKTLogZoneDynamic, APPLICATION_CONTEXT, LOG_FLAG_ERROR, __VA_ARGS__); \
    } \
} while (0)

#pragma mark - Migrations

typedef NS_ENUM(NSInteger, PKTMigrationType) {
    PKTMigrationTypeImmediate = 0
};

NS_ASSUME_NONNULL_BEGIN;

#if defined CocoaLumberjackAvailable

@interface DDAbstractLogger (PKTLoggingService)

@property (nonatomic, readwrite, strong) id<DDLogFormatter> PKTLoggingServiceLogFormatter;

- (void)configureLogFormatter:(Class)logFormatterClass
                configuration:(void(^)(id<DDLogFormatter>formatter))configuration;

@end

#endif

@protocol PKTItemSessionService <NSObject>

@property (nonatomic, copy, readonly) NSString *sessionId;

+ (id<PKTItemSessionService>)sharedInstance;

- (BOOL)startWithEvent:(NSString *)event item:(id<NSObject> _Nullable)item context:(NSDictionary *_Nullable)context;
- (BOOL)pauseWithEvent:(NSString *)event context:(NSDictionary *_Nullable)context;
- (BOOL)resumeWithEvent:(NSString *)event context:(NSDictionary *_Nullable)context;
- (BOOL)endWithEvent:(NSString *)event context:(NSDictionary *_Nullable)context;
- (void)reset;
- (BOOL)canResume;

@end

/**
 <PKTFutureRuntime> describes the interface of a runtime object that doesn't exist within the scope of this
 module, but is promised to exist during runtime. It provides a means of bridging the static library
 with application code.
 */

@protocol PKTAbstractFutureRuntime <NSObject>

- (id<PKTItemSessionService> _Nullable)itemSessionService;

@optional

#pragma mark - Custom Action Event Tracking

- (void)trackActionWithEvent:(NSString * _Nullable)event;

@end

@protocol PKTFutureRuntime <PKTAbstractFutureRuntime>

@property (class, nullable, nonatomic, readonly) NSString *sharedUserDefaultsSuiteName;

@property (nullable, nonatomic, readonly, strong) NSString *branchName;
@property (nonatomic, readonly, assign) BOOL sendActionsImmmediately;
@property (nonatomic, readonly, assign) BOOL useDescriptiveLoggingForActions;
@property (nullable, nonatomic, readonly, copy) NSString *username;
@property (nullable, nonatomic, readonly, copy) NSString *userID;

IMP PKTReplaceMethodWithBlock(Class klass, SEL toReplace, id block);

- (IMP)replaceMethodWithBlock:(Class)klass selector:(SEL)toReplace block:(id)block;

void PKTDebugColorAssign(UIView *v, UIColor *c);

void PKTDebugLabelApply(UIView *v, NSString *l);

@optional

+ (id<PKTFutureRuntime>)sharedRuntime;

- (id<PKTCryptor>)cryptor;
- (id<PKTCryptor>)keyGenerator;

- (id<PKTKeyValueStore>)store;

- (void)runMigrationType:(PKTMigrationType)type;

- (void)setupCrashReportingForCurrentUser;

- (void)logCustomEventWithName:(NSString *)eventName
              customAttributes:(nullable NSDictionary<NSString *, id> *)customAttributesOrNil;

@end

@interface PKTAbstractRuntime : NSObject <PKTFutureRuntime> {
@protected NSString *_APIDomain;
@protected NSString *_textEndpoint;
@protected NSString *_APIEndpoint;
@protected NSString *_userAgent;
}

@property (nonatomic, readonly, strong) NSString * _Nullable unmodifiedUserAgent;

/**
 @return NSString representation of Pocket API endpoint
 */

@property (nonnull, nonatomic, readonly) NSString *APIEndpoint;

/**
 @return NSString representation of Pocket text parser endpoint
 */

@property (nonatomic, readonly) NSString *textEndpoint;

/**
 @return NSString representation of Pocket API domain name
 */

@property (nonatomic, readonly) NSString *APIDomain;

/**
 @return NSString representation of user agent.
 */

@property (nonatomic, readonly, copy, nonnull) NSString *userAgent;

/**
 @return shared user defaults suite name
 */

@property (nonatomic, readonly, nullable) NSString *sharedUserDefaultsSuiteName;

/**
 @return id<PKTImageCacheManagement> conformant object for image cache management.
 */

@property (nonatomic, readonly, weak) id<PKTImageCacheManagement> imageCache;

/**
 @return The user name associated with the logged in user.
 @note This value is considered private user data and should not be used in production builds.
 */

@property (nullable, nonatomic, readonly, copy) NSString *username;

/**
 @return The user identifier associated with the logged in user.
 */

@property (nullable, nonatomic, readonly, copy) NSString *userID;

- (void)start NS_REQUIRES_SUPER;

- (void)stop NS_REQUIRES_SUPER;

- (void)setupConsoleLogging:(BOOL)enabled;

- (IMP)replaceMethodWithBlock:(Class)klass
                     selector:(SEL)toReplace
                        block:(id)block;

IMP PKTReplaceMethodWithBlock(Class klass, SEL toReplace, id block);

@end

@interface PKTCoreLogging : NSObject

@property (nonatomic, readonly, class) Class<PKTFutureRuntime> localRuntimeClass;
@property (nonatomic, readonly, class) PKTAbstractRuntime<PKTFutureRuntime>* localRuntime;

NSURL * PKTContainerURL(NSString * subdirectory, BOOL excludeFromBackup);

NSURL * PKTDataDirectoryURL(void);

NSURL * PKTSupportDataDirectoryURL(NSString * groupName);

NSURL * PKTListenSupportDataDirectoryURL(NSString * groupName);

BOOL isDebuggerAttached(void);

NSString * PKTConsumerKey(void);

void PKTSetGUID(NSString *_Nullable token);

void PKTSetAccessToken(NSString *_Nullable guid);

void PKTSetConsumerKey(NSString *_Nullable consumerKey);

NSString *_Nullable PKTAccessToken(void);

/**
 Returns a commmon JSON store that can be used to share values between the Pocket host app
 and its extensions
 */

id<PKTKeyValueStore> _Nonnull PKTSharedKeyStore(void);

NSString *_Nullable PKTBuildBranchName(void);

@end

#define POCKET_DOMAIN ({ [[PKTCoreLogging localRuntime] APIDomain]; })
#define API_ENDPOINT  ({ [[PKTCoreLogging localRuntime] APIEndpoint]; })
#define TEXT_ENDPOINT  ({ [[PKTCoreLogging localRuntime] textEndpoint]; })
#define PKTSharedUserDefaultsSuiteName  ({ [[PKTCoreLogging localRuntimeClass] sharedUserDefaultsSuiteName]; })

NS_ASSUME_NONNULL_END;

