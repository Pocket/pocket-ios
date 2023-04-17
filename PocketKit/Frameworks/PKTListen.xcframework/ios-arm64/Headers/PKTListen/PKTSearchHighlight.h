//
//  PKTSearchHighlight.h
//  PKTRuntime
//
//  Created by Larry Tran on 10/25/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTSearchHighlightString : NSObject
@property (nonatomic, strong, readonly) NSArray <NSString *>*tokens;
@property (nonatomic, strong, readonly) NSString *text;
@end

@interface PKTSearchHighlight : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)init __unavailable;

@property (nonatomic, strong, readonly) PKTSearchHighlightString *title;
@property (nonatomic, strong, readonly) PKTSearchHighlightString *url;
@property (nonatomic, strong, readonly) PKTSearchHighlightString *fullText;
@property (nonatomic, strong, readonly) PKTSearchHighlightString *tag;

@end

NS_ASSUME_NONNULL_END
