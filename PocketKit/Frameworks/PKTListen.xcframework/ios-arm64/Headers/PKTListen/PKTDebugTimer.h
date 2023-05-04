//
//  PKTDebugTimer.h
//  RIL
//
//  Created by Nicholas Zeltzer on 8/28/16.
//
//

@import Foundation;
@import UIKit;

@class PKTDebugTimer;

@protocol PKTDebugTimerDelegate <NSObject>

- (void)timer:(nonnull PKTDebugTimer*)timer didRecordTime:(nonnull NSDate*)time withTag:(nonnull NSString*)tag;
- (void)timer:(nonnull PKTDebugTimer*)timer didFinishWithAnnouncment:(nonnull NSString*)announcement;

@end


/**
 PKTDebugTimer is a class used for measuring the time it takes for a process to complete.
 When the DEBUG macro is not defined, all intialization calls will return 'nil', making it safe to leave in place for production code.
 @note Given that the availability of a timer instance depends on the build configuration, one should _never_ place a timer instance into a collection – always assume it is nil.
 */

#if TARGET_OS_IPHONE
UIKIT_EXTERN NSString *__nonnull const kPKTTimerTime;
UIKIT_EXTERN NSString *__nonnull const kPKTTimerTag;
#else
FOUNDATION_EXPORT NSString *__nonnull const kPKTTimerTime;
FOUNDATION_EXPORT NSString *__nonnull const kPKTTimerTag;
#endif


@interface PKTDebugTimer : NSObject

@property (readonly, nullable) NSString *message;
@property (assign, nullable) id <PKTDebugTimerDelegate> delegate;
@property (readonly, assign) NSTimeInterval duration;

+ (nullable instancetype)sharedTimer;
- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithTag:(nonnull NSString*)firstTimeTag;
- (nullable instancetype)initWithTagWithFormat:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (nullable instancetype)initWithMessageIncrement:(NSUInteger)increment;

- (void)recordTimeWithTag:(nonnull NSString *)tag;
- (void)recordTimeWithFormat:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)finish;
- (void)finishAndReport;
- (void)finishAndAnnounce;
- (void)clearEvents;

+ (void)setDisableAllReports:(BOOL)disableAllReports;

@end
