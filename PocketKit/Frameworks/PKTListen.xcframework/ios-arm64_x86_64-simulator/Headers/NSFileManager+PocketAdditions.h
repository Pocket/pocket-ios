//
//  NSFileManager+PocketAdditions.h
//  RIL
//
//  Created by Nate Weiner on 12/5/11.
//  Copyright (c) 2011 Pocket. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (PocketAdditions)

/// Get a file manager, defaultManager is not thread safe and you should be creating one when you need it on a thread
+ (NSFileManager *)safeManager;

- (BOOL)fileExistsAtURL:(NSURL *_Nonnull)fileURL
            isDirectory:(inout BOOL *)isDirectory;

@end

NS_ASSUME_NONNULL_END
