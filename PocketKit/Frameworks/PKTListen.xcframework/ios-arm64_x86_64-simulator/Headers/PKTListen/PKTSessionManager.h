//
//  PKTSessionManager.h
//  RIL
//
//  Created by Steve Streza on 5/25/12.
//  Copyright (c) 2012 Read It Later, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PKTSessionManager : NSObject

+ (PKTSessionManager *)sharedInstance;
- (void)expireImmediately;

@property (nonatomic, copy) void (^sessionIdChanged)(NSString *sessionId);
@property (nonatomic, readonly, strong) NSString *sessionID;
@property (nonatomic, readonly, strong) NSDate *timeout;

@end
