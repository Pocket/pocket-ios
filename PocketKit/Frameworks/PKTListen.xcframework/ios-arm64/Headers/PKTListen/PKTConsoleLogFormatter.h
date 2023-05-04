//
//  PKTConsoleLogFormatter.h
//  Pocket
//
//  Created by Nik
//
//

/**
 PKTConsoleLogFormatter is a log formatter, used to format the output of stdout.
 */

#if defined CocoaLumberjackAvailable

#import "CocoaLumberjack/CocoaLumberjack.h";

@interface PKTConsoleLogFormatter : DDContextBlacklistFilterLogFormatter

@property (nonatomic, readwrite, assign) NSInteger logFlagWhiteList;

@end
#endif
