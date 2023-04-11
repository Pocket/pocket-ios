//
//  Position.h
//  RIL
//
//  Created by Nathan Weiner on 11/6/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

@import UIKit;

#import "PKTSharedEnums.h"
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTPosition : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary  NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

@property (assign, nonatomic, readonly) RILViewType view;
@property (assign, nonatomic, readonly) int section;
@property (assign, nonatomic, readonly) int page;
@property (assign, nonatomic, readonly) int nodeIndex;
@property (assign, nonatomic, readonly) int percent;
@property (assign, nonatomic, readonly) int timeUpdated;
@property (assign, nonatomic, readonly) int timeSpent;

@end

NS_ASSUME_NONNULL_END
