//
//  PKTShare.h
//  RIL
//
//  Created by Nate Weiner on 8/28/12.
//  Copyright (c) 2012 Read It Later. All rights reserved.
//

#import "PKTModelCodable.h"

@import Foundation;

@class PKTFriend;

NS_ASSUME_NONNULL_BEGIN

@interface PKTShare : NSObject <PKTModelCodable>

+ (PKTShare *_Nullable)shareFromDictionary:(NSDictionary *)dictionary;

@property (strong, nonatomic) NSNumber *uniqueId;
@property (strong, nonatomic) NSNumber *itemId;
@property (strong, nonatomic) NSNumber *shareId;
@property (copy, nonatomic, readonly) NSString *friendId;
@property (strong, nonatomic) PKTFriend *fromFriend;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *quote;
@property (assign, nonatomic) NSTimeInterval timeShared;
@property (strong, nonatomic) NSNumber *status;
@property (copy, nonatomic, readonly) NSString *userEmail;
@property (assign, nonatomic, getter=isQuoteExpanded) BOOL quoteExpanded;
@property (assign, nonatomic, readonly, getter=isPending) BOOL pending;

/// Return the full name of the friend
@property (nonatomic, copy, readonly) NSString *fromName;

@end

NS_ASSUME_NONNULL_END
