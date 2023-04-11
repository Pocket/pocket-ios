//
//  PKTFileObserver.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 5/22/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/** A manager for observing changes to files on disk and notifying interested observers. */

@interface PKTFileObserver : NSObject

+ (instancetype)defaultObserver;

- (id<NSObject>)addObserverForURL:(nonnull NSURL *)fileURL
                            queue:(nullable NSOperationQueue *)queue
                       usingBlock:(void (^)(NSURL *fileURL))block;

- (void)removeObserver:(id<NSObject>)observer;

@end
NS_ASSUME_NONNULL_END
