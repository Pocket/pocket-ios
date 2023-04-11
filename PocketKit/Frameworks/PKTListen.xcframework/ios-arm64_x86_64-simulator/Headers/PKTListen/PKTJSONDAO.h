//
//  PKTJSONDAO.h
//  RIL
//
//  Created by Nicholas Zeltzer on 4/24/17.
//
//

#import "PKTKeyValueStore.h"

/**
 PKTJSONDAO is a lightweight JSON-backed DAO. It will accept any valid JSON key/value pair. 
 All mutations trigger the DAO to write to the file URL provided during instantiation.
 */

@protocol PKTCryptor;

NS_ASSUME_NONNULL_BEGIN

@interface PKTJSONDAO <__covariant T:id<NSObject, NSCopying, NSCoding>> : NSObject <PKTKeyValueStore>

@property (nonnull, nonatomic, readonly, copy) NSURL * presentedItemURL;
@property (nonnull, nonatomic, readonly, copy) NSDictionary * userInfo;

+ (instancetype)defaultStoreWithCryptor:(id<PKTCryptor>)cryptor;

- (instancetype)initWithFileURL:(NSURL *_Nonnull)fileURL;
- (instancetype)initWithFileURL:(NSURL *_Nonnull)fileURL cryptor:(nullable id<PKTCryptor>)cryptor NS_DESIGNATED_INITIALIZER;

- (T _Nullable)objectForKeyedSubscript:(id<NSCopying, NSObject> _Nonnull)key;

- (void)setObject:(T _Nullable)obj forKeyedSubscript:(id<NSCopying, NSObject> _Nonnull)key;

- (T _Nullable)valueForKey:(NSString *)key;

- (void)setValue:(T _Nullable)value forKey:(NSString *)key;

- (void)removeValueForKey:(NSString *_Nullable)key;

/** Force reloading the DAO from disk. */

- (void)reload;

@end

NS_ASSUME_NONNULL_END
