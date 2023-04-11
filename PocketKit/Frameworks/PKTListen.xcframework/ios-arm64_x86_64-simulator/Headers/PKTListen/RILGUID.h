//
//  RILGUID.h
//  RIL
//
//  Created by Nate Weiner on 12/3/11.
//  Copyright (c) 2011 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIRequestGate.h"

@class PKTAPIRequest;

@interface RILGUID : APIRequestGate

@property (nonatomic) BOOL fetching;

+ (instancetype)mainGUID;
- (NSString *)guid;

@end
