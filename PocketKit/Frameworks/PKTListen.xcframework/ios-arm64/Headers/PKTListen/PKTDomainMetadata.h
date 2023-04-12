//
//  PKTDomainMetadata.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 10/1/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKTDomainMetadata : NSObject

@property (nonatomic, readonly, strong, nullable) NSURL *greyscaleLogoURL;
@property (nonatomic, readonly, strong, nullable) NSURL *logoURL;
@property (nonatomic, readonly, copy, nullable) NSString *domainName;
@property (nonatomic, readonly, copy, nullable) NSString *itemID;
@property (nonatomic, readonly, copy, nullable) NSString *uniqueID;

- (nullable instancetype)initWithDictionary:(NSDictionary *_Nullable)userInfo;

+ (nullable instancetype)fromDictionary:(NSDictionary *_Nullable)userInfo;

- (NSDictionary *_Nonnull)dictionaryRepresentation;

@end

#pragma mark PKTDomainMetadata+PKTImageResource

@protocol PKTImageResource;

@interface PKTDomainMetadata (PKTImageResource) <PKTImageResource>

@end

#pragma mark PKTDomainMetadata+PKTJSONParser

@class PKTJSONParser;

@interface PKTDomainMetadata (PKTJSONParser)

+ (PKTJSONParser *)parser;

@end

NS_ASSUME_NONNULL_END
