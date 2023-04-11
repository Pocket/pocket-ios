//
//  PKTFeedItemImpressionTimer.h
//  RIL
//
//  Created by Larry Tran on 5/12/16.
//
//

#import <Foundation/Foundation.h>

@interface PKTFeedItemImpressionTimer : NSObject

- (instancetype)initWithMaxTime:(NSTimeInterval)maxTime;

/// Starts a timer that will be fired at the given max time
- (void)start;

/// Resets the the timer to its initial state
- (void)reset;

/// Threshold for when the timer expires
@property (nonatomic, assign, readonly) NSTimeInterval maxTime;

/// Lets the receiver know if the timer has reached its given max time
@property (nonatomic, assign, readonly) BOOL maxTimeReached;

/// Call back for the receiver once the max time has been reached
@property (nonatomic, copy) void (^maxTimeReachedCallBack)(void);

@end
