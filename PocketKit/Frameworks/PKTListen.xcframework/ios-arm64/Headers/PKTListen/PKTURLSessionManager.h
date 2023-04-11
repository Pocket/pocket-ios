//
//  PKTURLSessionManager.h
//  Pocket
//
//  Created by Nicholas Zeltzer on 6/28/18.
//

#import <Foundation/Foundation.h>
#import "NSURLSessionTask+PKTAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTURLSessionManager : NSObject <NSURLSessionDataDelegate>

@property (nonnull, nonatomic, readonly) dispatch_queue_t networkQueue;
@property (nonnull, nonatomic, readonly) NSURLSession *pocketSession;
@property (nonnull, nonatomic, readonly) NSURLSession *defaultSession;
@property (nonnull, nonatomic, readonly) NSOperationQueue *sessionDelegateOperationQueue;

+ (instancetype)sharedManager;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                    completionHandler:(void (^)(NSURL * _Nullable location,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     redirect:(PKTNetworkTaskShouldCompleteWithRedirect)redirect
                            completionHandler:(void (^)(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error))completionHandler;

- (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(PKTNetworkTaskDidUpdate)progress
                                    completionHandler:(void (^)(NSURL * _Nullable location,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error))completionHandler;

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     progress:(PKTNetworkTaskDidUpdate)progress
                            completionHandler:(void (^)(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
