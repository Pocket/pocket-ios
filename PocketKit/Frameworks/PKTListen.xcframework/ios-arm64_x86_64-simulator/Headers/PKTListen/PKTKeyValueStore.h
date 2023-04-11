//
//  PKTKeyValueStore.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 11/20/17.
//  Copyright © 2017 Pocket. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 PKTKeyValueStore defines an abstract interface for a Key Value Store (KVS).
 */

@protocol PKTKeyValueStore <NSObject>

@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;

/**
 @return an instance of <PKTKeyValueStore> persisted at the provided fileURL.
 @note If a KVS does not exist at the designated location, a new KVS associated with this URL should be returned.
 */

- (nonnull instancetype)initWithFileURL:(NSURL *_Nonnull)fileURL;

- (id _Nullable)objectForKeyedSubscript:(id<NSCopying, NSObject> _Nonnull)key;

- (void)setObject:(id _Nullable)obj
forKeyedSubscript:(id<NSCopying, NSObject> _Nonnull)key;

- (id _Nullable)valueForKey:(NSString *_Nonnull)key;
- (nullable id)objectForKey:(NSString *)defaultName;

- (void)setValue:(id _Nullable)value forKey:(NSString *_Nonnull)key;
- (void)setObject:(nullable id)value forKey:(NSString *)defaultName;

- (void)removeValueForKey:(NSString *_Nullable)key;
- (void)removeObjectForKey:(NSString *)defaultName;

- (nullable NSString *)stringForKey:(NSString *)defaultName;
- (nullable NSArray *)arrayForKey:(NSString *)defaultName;
- (nullable NSDictionary *)dictionaryForKey:(NSString *)defaultName;
- (nullable NSData *)dataForKey:(NSString *)defaultName;
- (nullable NSArray<NSString *> *)stringArrayForKey:(NSString *)defaultName;
- (nullable NSURL *)URLForKey:(NSString *)defaultName;
- (NSInteger)integerForKey:(NSString *)defaultName;
- (float)floatForKey:(NSString *)defaultName;
- (double)doubleForKey:(NSString *)defaultName;
- (BOOL)boolForKey:(NSString *)defaultName;

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName;
- (void)setFloat:(float)value forKey:(NSString *)defaultName;
- (void)setDouble:(double)value forKey:(NSString *)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString *)defaultName;
- (void)setURL:(nullable NSURL *)url forKey:(NSString *)defaultName;

- (void)mergeWithDictionary:(NSDictionary<NSString *, id> *)dictionary;
- (void)registerDefaults:(NSDictionary<NSString *, id> *)defaults;

@end

NS_ASSUME_NONNULL_END
