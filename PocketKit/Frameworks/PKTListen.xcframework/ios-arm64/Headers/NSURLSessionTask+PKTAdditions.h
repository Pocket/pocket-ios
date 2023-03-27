//
//  NSURLSessionTask+PKTAdditions.h
//  Pocket
//
//  Created by Nicholas Zeltzer on 6/28/18.
//

#import <Foundation/Foundation.h>

// The PKTDataTaskProgressHandler is always called on the main thread.
typedef void (^PKTNetworkTaskDidUpdate)(NSURLSessionTask *_Nonnull task, CGFloat progress, BOOL finished);
typedef BOOL (^PKTNetworkTaskShouldCompleteWithRedirect)(NSURLRequest * _Nullable);

@interface NSURLSessionTask (PKTAdditions)

@property (nonatomic, readwrite, assign) NSInteger maxDataLength;
@property (nullable, nonatomic, readwrite, copy) PKTNetworkTaskDidUpdate progressDidUpdate;
@property (nullable, nonatomic, readwrite, copy) PKTNetworkTaskShouldCompleteWithRedirect progressDidRedirect;
@property (nonnull, nonatomic, readonly, copy) NSData *data;

- (void)appendData:(NSData *_Nonnull)data;

@end
