//
//  PKTRequestURLSession.h
//  RIL
//
//  Created by Scott J. Kleper on 7/8/15.
//
//

#import "NSURLSessionTask+PKTAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTDataTask : NSObject

+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                   completion:(void (^)(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error))completion;

+ (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                           completion:(void (^)(NSURL * _Nullable location,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error))completion;

/* An HTTP request is attempting to perform a redirection to a different
 * URL. You must invoke the redirection block to allow the
 * redirection, pass YES to the redirect block to cancel the request for custom redirect handling,
 * pass NO to let the redirection continue.
 * Note: If YES is passed inside the redirect handler an error will be passed into the completion handler
 */
+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     redirect:(nullable PKTNetworkTaskShouldCompleteWithRedirect)redirect
                                   completion:(void (^)(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error))completionHandler;

+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                     progress:(nullable PKTNetworkTaskDidUpdate)progress
                                   completion:(void (^)(NSData * _Nullable data,
                                                        NSURLResponse * _Nullable response,
                                                        NSError * _Nullable error))completion;

+ (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(nullable PKTNetworkTaskDidUpdate)progress
                                           completion:(void (^)(NSURL * _Nullable location,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error))completion;

+ (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
                                   method:(NSString *)method
                                   params:(nullable NSDictionary *)params
                                  headers:(nullable NSDictionary *)headers
                               completion:(void(^)(NSData *data,
                                                   NSURLResponse *response,
                                                   NSError *error))completion;

+ (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url
                                   method:(NSString *)method
                                 bodyData:(NSData *)bodyData
                                  headers:(nullable NSDictionary *)headers
                               completion:(void(^)(NSData *data,
                                                   NSURLResponse *response,
                                                   NSError *error))completion;

+ (NSMutableURLRequest *)URLRequestWithURL:(NSURL *)url
                                    method:(NSString *)method
                                   headers:(nullable NSDictionary *)headers
                                    params:(nullable NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
