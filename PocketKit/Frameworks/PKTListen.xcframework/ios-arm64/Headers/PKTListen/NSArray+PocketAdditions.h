//
//  NSArray+PocketAdditions.h
//  RIL
//
//  Created by Steve Streza on 10/17/12.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id __nullable (^PKTMapBlock)(id __nonnull obj);
typedef id __nullable (^PKTMapFunc)(id, NSInteger, id);
typedef id _Nullable (^PKTReduceFunc)(id accumulator, NSArray<id>* source, NSInteger idx, id value);
#define PKTMapping(from, to) ^to*(from *obj)

@interface NSArray <__covariant ObjectType> (PocketAdditions)

@property (nullable, nonatomic, readonly) NSArray <ObjectType> *tail;

/// Returns the count of the NSArray as NSInteger
@property (assign, nonatomic, readonly) NSInteger signedCount;

@property (nonnull, nonatomic, readonly) NSArray * (^joined)(NSArray *toJoin);

@property (nonnull, nonatomic, readonly) NSArray * (^mapped)(PKTMapBlock block);

@property (nonnull, nonatomic, readonly) NSInteger (^index)(ObjectType _Nullable obj);

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> * (^filtered)(BOOL (^filter)(ObjectType obj));

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> *_Nonnull (^added)(ObjectType _Nullable obj);

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> *_Nonnull (^removed)(ObjectType _Nullable obj);

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> *_Nonnull (^pushed)(ObjectType _Nullable obj);

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> *_Nonnull (^popped)(void);

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> *_Nonnull (^replaced)(ObjectType _Nullable replace, ObjectType _Nullable with);

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> * (^sorted)(NSComparisonResult (^block)(ObjectType obj1, ObjectType obj2));

@property (nonnull, nonatomic, readonly) NSArray <ObjectType> *_Nonnull (^flatMapped)(PKTMapFunc map);

@property (nonnull, nonatomic, readonly) id _Nonnull (^reduced)(id accumulator, id (^reducer)(id accumulator, NSArray<ObjectType>* source, NSInteger idx, ObjectType value));

@property (nonnull, nonatomic, readonly) BOOL (^isFirst)(ObjectType _Nullable value);

@property (nonnull, nonatomic, readonly) BOOL (^isLast)(ObjectType _Nullable value);

@property (nonnull, nonatomic, readonly) ObjectType _Nullable (^next)(ObjectType _Nullable value);

@property (nonnull, nonatomic, readonly) ObjectType _Nullable (^previous)(ObjectType _Nullable value);

@property (nonnull, nonatomic, readonly) NSArray<ObjectType> *_Nonnull (^after)(ObjectType _Nullable value);

@property (nonnull, nonatomic, readonly) NSArray<ObjectType> *_Nonnull (^before)(ObjectType _Nullable value);

@property (nullable, nonatomic, readonly) NSArray *JSONObject;

@property (nullable, nonatomic, readonly) NSData *JSONData;

@property (nonnull, nonatomic, readonly) NSOrderedSet *orderedSet;

/// Produces a new array of values by mapping each value in list through a block.
- (NSArray *)arrayByMappingObjectsWithBlock:(id (^)(id object, NSUInteger index))block;

/// Looks through each value in the receiver, returning a new NSArray of all the values that pass a truth test
- (NSArray *)arrayByFilteringObjectsWithBlock:(BOOL (^)(id obj, NSUInteger index))test;

/// A convenient version of what is perhaps the most common use-case for map: extracting a list of property values.
- (NSArray *)arrayByPluckingObjectsWithKeyPath:(NSString *)keyPath;

/// Returns a new array by removing the object from the receiver
- (NSArray *)arrayByRemovingObject:(id)object;

/// Returns a new array by removing an object at a given index from the receiver
- (NSArray *)arrayByRemovingObjectAtIndex:(NSUInteger)index;

/// Returns a new array by removing objects based on the given NSIndexSet from the receiver
- (NSArray *)arrayByRemovingObjectsAtIndexes:(NSIndexSet *)indexes;

/// Returns a new array by replacing a given object at the given index
- (NSArray *)arrayByReplacingObjectAtIndex:(NSUInteger)index withObject:(id)object;

@end

@interface NSMutableArray <ObjectType> (PKTPocketAdditions)

@property (nonnull, nonatomic, readonly) NSMutableArray * (^join)(NSArray *toJoin);

/**
 @example NSArray *mapped = original.mapped(^id(id obj) { return obj; });
 */

@property (nonnull, nonatomic, readonly) NSMutableArray * (^map)(PKTMapBlock block);

@property (nonnull, nonatomic, readonly) NSMutableArray <ObjectType> * (^filter)(BOOL (^filter)(ObjectType obj));

@property (nonnull, nonatomic, readonly) NSMutableArray <ObjectType> *_Nonnull (^add)(ObjectType _Nullable obj);

@property (nonnull, nonatomic, readonly) NSMutableArray <ObjectType> * (^sort)(NSComparisonResult (^block)(ObjectType obj1, ObjectType obj2));

@property (nonnull, nonatomic, readonly) NSMutableArray <ObjectType> *_Nonnull (^flatMap)(PKTMapFunc map);

@end

NS_ASSUME_NONNULL_END
