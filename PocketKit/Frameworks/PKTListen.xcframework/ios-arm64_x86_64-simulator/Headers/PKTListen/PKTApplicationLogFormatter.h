//
//  PKTApplicationFileLogger.h
//  Pocket
//
//  Created by Nik
//
//

@import Foundation;

/**
 PKTApplicationFileLogger is a file logging client used to write log files to disk.
 */

#if defined CocoaLumberjackAvailable
#import "CocoaLumberjack/CocoaLumberjack.h"
#import "CocoaLumberjack/DDContextFilterLogFormatter.h"

NS_ASSUME_NONNULL_BEGIN;

@class PKTApplicationLogFormatter;

#pragma mark - PKTApplicationLogFormatterDelegate

@protocol PKTApplicationLogFormatterDelegate <NSObject>

@required

- (void)formatter:(PKTApplicationLogFormatter *_Nonnull)formatter
      didEmitLine:(NSString *_Nonnull)logLine
              tag:(NSDictionary *_Nullable)logTag;

@end

#pragma mark - PKTApplicationFileLogger

@interface PKTApplicationFileLogger : DDFileLogger

+ (instancetype)sharedInstance;

@end

#pragma mark - PKTApplicationLogFormatter

@interface PKTApplicationLogFormatter : DDContextBlacklistFilterLogFormatter {
@protected NSInteger _logFlagWhiteList;
}

@property (nonatomic, readwrite, assign) NSInteger logFlagWhiteList;
@property (nullable, nonatomic, readwrite, weak) id<PKTApplicationLogFormatterDelegate> delegate;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

+ (instancetype)sharedInstance;

@end

#pragma mark - PKTListenFileLogger

@interface PKTListenFileLogger : DDFileLogger

+ (instancetype)sharedInstance;

@end

#pragma mark - PKTListenLogFormatter

@interface PKTListenLogFormatter : PKTApplicationLogFormatter

@property (nonatomic, readwrite, assign) NSInteger logFlagWhiteList;
@property (nullable, nonatomic, readwrite, weak) id<PKTApplicationLogFormatterDelegate> delegate;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

+ (instancetype)sharedInstance;

@end
NS_ASSUME_NONNULL_END;
#endif

