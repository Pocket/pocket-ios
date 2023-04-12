//
//  PKTImageResource.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 9/22/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PKTImageResource <NSObject>

@property (nonatomic, readonly, assign) BOOL imageIsEphemeral;

@property (nonatomic, readonly, strong, nullable) NSString *imageResourceID;
@property (nonatomic, readonly, strong, nullable) NSURL *imageResourceURL;
@property (nonatomic, readonly, strong, nullable) NSURL *fallbackResourceURL;
@property (nullable, nonatomic, readonly, strong) NSURLRequest *imageResourceRequest;

@end

NS_ASSUME_NONNULL_END
