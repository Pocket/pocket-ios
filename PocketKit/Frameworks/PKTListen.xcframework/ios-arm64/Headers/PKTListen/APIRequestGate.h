//
//  APIRequestGate.h
//  RIL
//
//  Created by Steve Streza on 8/13/12.
//
//  Used if you need an interstitial step before making API requests.

#import <Foundation/Foundation.h>

@class PKTAPIRequest;

NS_ASSUME_NONNULL_BEGIN

@interface APIRequestGate : NSObject

@property (atomic, strong, readonly) NSMutableArray *pendingRequests;

- (void)addPendingRequest:(PKTAPIRequest *)request;
- (void)startPendingRequests;

// implement these in subclasses
- (BOOL)canPerformRequest:(PKTAPIRequest *)request;
- (void)processGate;
- (BOOL)checkForRequest:(PKTAPIRequest *)request;

@end

NS_ASSUME_NONNULL_END
