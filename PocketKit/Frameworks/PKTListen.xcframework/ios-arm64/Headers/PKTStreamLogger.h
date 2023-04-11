//
//  PKTStreamLogger.h
//  Pocket
//
//  Created by Nik
//
//

/**
 PKTStreamLogger is an optional logger that can be used to pipe logging over Bonjour to a console log display, using NSLogger.
 */

#if defined CocoaLumberjackAvailable && defined NSLoggerAvailable
#import "CocoaLumberjack/CocoaLumberjack.h"

@interface PKTStreamLogger : DDAbstractLogger <DDLogger>

+ (instancetype)sharedInstance;
- (void)start;
- (void)stop;

@end
#endif
