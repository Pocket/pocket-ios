//
//  LPKTListenConformance.h
//  Pocket
//
//  Created by Nicholas Zeltzer on 9/11/18.
//

#import "ListDataOperation.h"

#define PKTListenEnabled 1

NS_ASSUME_NONNULL_BEGIN
#if PKTListenEnabled

@protocol PKTListenConformance <NSObject>

- (void)saveAuthors:(NSString *)uniqueID authors:(NSDictionary<NSString*, NSString*>*)authors replace:(BOOL)replace;

- (void)deleteAuthors:(NSString *_Nullable)itemID;

- (void)saveDomainMetadata:(NSDictionary<NSString*, NSString*>*)obj replace:(BOOL)replace;

- (void)deleteDomainMetadata:(NSString *_Nullable)itemID;

@end

@interface ListDataOperation (PKTListen) <PKTListenConformance>

- (void)saveAuthors:(NSString *)uniqueID authors:(NSDictionary<NSString*, NSString*>*)authors replace:(BOOL)replace;

- (void)deleteAuthors:(NSString *_Nullable)itemID;

- (void)saveDomainMetadata:(NSDictionary<NSString*, NSString*>*)obj replace:(BOOL)replace;

- (void)deleteDomainMetadata:(NSString *_Nullable)itemID;

@end

#endif
NS_ASSUME_NONNULL_END
