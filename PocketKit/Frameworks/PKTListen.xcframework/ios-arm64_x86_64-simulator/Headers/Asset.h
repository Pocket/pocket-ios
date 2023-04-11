//
//  Asset.h
//  RIL
//
//  Created by Nathan Weiner on 11/9/10.
//  Copyright 2010 Idea Shower, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AssetManager;

NS_ASSUME_NONNULL_BEGIN

@interface Asset : NSObject

@property (nonatomic, strong) AssetManager *assetManager;
@property (nonatomic, strong) NSMutableDictionary *info;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, copy)	NSString * _Nullable absolute;
@property (nonatomic, copy)	NSString *domain;
@property (nonatomic, copy)	NSString *localPath;
@property (nonatomic, copy)	NSString *relativePath;
@property (nonatomic, copy)	NSString *truncatedPath;
@property (nonatomic, copy)	NSString *localPathHead;
@property (nonatomic, copy)	NSString *filename;
@property (nonatomic, copy)	NSString *extension;
@property (nonatomic, assign) BOOL checkedExists;
@property (nonatomic, assign) BOOL doesExist;
@property (nonatomic, assign) BOOL temporary;

+ (instancetype)assetFromUrl:(NSString *)url;
+ (instancetype)assetFromUrl:(NSString *)url temporary:(BOOL)temporary;
+ (instancetype)assetFromLiteral:(NSString *)literal baseURL:(NSURL *)base forceType:(int)forceType;

#pragma mark -

- (instancetype)init;
- (instancetype)initWithLiteral:(NSString *)literal baseURL:(NSURL *)base forceType:(int)forceType;

- (BOOL)parseLiteral:(NSString *)literal withBaseURL:(NSURL *)base forceType:(int)forceType;

#pragma mark -

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
- (BOOL)exists;

- (NSString *)relativePath;
- (NSString *)truncatedPath;

#pragma mark -

- (void)remove;

#pragma mark -

- (void)addImageDimensionCheckData:(NSNumber *)imageId uniqueId:(NSNumber *)uniqueId currentSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
