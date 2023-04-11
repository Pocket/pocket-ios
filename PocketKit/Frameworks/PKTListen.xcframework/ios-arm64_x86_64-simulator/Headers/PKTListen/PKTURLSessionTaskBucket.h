//
//  PKTURLSessionTaskBucket.h
//  Pocket
//
//  Created by Nicholas Zeltzer on 6/28/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKTURLSessionTaskBucket : NSObject

@property (nonatomic, readonly, assign) NSInteger identifier;


+ (PKTURLSessionTaskBucket *)pourBucketForDataTask:(NSURLSessionDataTask *)task
                                        completion:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completion;

+ (PKTURLSessionTaskBucket *)pourBucketForDownloadTask:(NSURLSessionDownloadTask *)task
                                    completion:(void(^)(NSURL *location, NSURLResponse *response, NSError *error))completion;

+ (void)emptyBucketForTask:(NSURLSessionDataTask *)task
                      data:(NSData *_Nullable)data
                     error:(NSError *_Nullable)error;

+ (void)emptyBucketForTask:(NSURLSessionDownloadTask *)task
                  location:(NSURL *_Nullable)location
                     error:(NSError *_Nullable)error;


@end

NS_ASSUME_NONNULL_END
