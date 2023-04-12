//
//  PKTKusari.h
//  RIL
//
//  Created by Nicholas Zeltzer on 4/18/17.
//
//

#import <Foundation/Foundation.h>

#import "NSArray+PocketAdditions.h"
#if defined IGListKitEnabled
#import "IGListKit/IGListKit.h"
#endif


/** PKTKusari is an immutable list-like data structure that can be used to create the render model for IGListKit-backed views.
 
 Internally, PKTKusari wraps two different immutable data structures: <NSDictionary> and <NArray>. The <NSDictionary> is provided as a light weight method of associated small amounts of context with a given list. 
 
 PKTKusari is not mutable. Methods like, "join", "replace", etc, are provided as chainable block properties, the product of which will be a _new_ PKTKusari object. 
 
 PKTKusari are collection objects, and can be instantiated with a specific object type, e.g., 
 
    PKTKusari<NSString*> *strings = ...
 
 All PKTKusari objects are created with PKTKusariCreate function. A unique ID is required. An arbitrary integer value may be provided to differentiate "types" of Kusari from one another without relying on the userInfo property.
 
    PKTKusari<NSString*> *strings = PKTKusariCreate(@"My Strings Collection", 0);
 
 PKTKusari conform to <IGListDiffable> through the PKTListDiffable protocol extension.
 
 This allows a given Kusari to either be used as an element in an IGListKit-backed view, or as a container for view 
 elements. This is useful for creating matrix-like data structures, where one kusari manages a series of elements that
 should be rendered as individual views, while another manages a different list of elements that, together, should be 
 rendered as a single view, or as a single view state.
 
 [ ]
 [ ][ ][ ]
 [ ]
 [ ][ ][ ]
    [ ][ ]
    [ ]
 
 */

NS_ASSUME_NONNULL_BEGIN

@protocol PKTListDiffable;
@protocol PKTListComparable;

#pragma mark - PKTListComparable

@protocol PKTListComparable <NSObject>

@property (nonatomic, readonly, strong, nonnull) NSDictionary<id<NSObject>, id<NSObject>> *comparison;

@end

#pragma mark - PKTListDiffable

#if defined IGListKitEnabled
@protocol PKTListDiffable <IGListDiffable, NSObject>
#else
@protocol PKTListDiffable <NSObject>
#endif

- (nonnull id<NSObject>)diffIdentifier;

- (BOOL)isEqualToDiffableObject:(nullable id<PKTListDiffable>)object;

@optional

@property (nonnull, nonatomic, readonly) NSString *kusariDescription;

@end

#pragma mark - <PKTKusari>

/**  PKTKusari is an immutable list-like data structure that associates a list of <PKTListDiffable> objects. */

@protocol PKTKusari <PKTListDiffable, PKTListComparable, NSObject>

@property (nonatomic, readonly, assign) NSInteger type;
@property (nonnull, nonatomic, readonly, copy) NSString *uniqueID;
@property (nonnull, nonatomic, readonly, copy) NSOrderedSet<id<PKTListDiffable>> *list;
@property (nonnull, nonatomic, readonly, copy) NSDictionary *userInfo;
@property (nonnull, nonatomic, readonly, copy) NSOrderedSet <id<PKTListDiffable>> *composedList;

/** @return A new instance of the receiver's class, with the list contents appended. */
@property (nonnull, nonatomic, readonly) id<PKTKusari> (^join)(NSOrderedSet<id<PKTListDiffable>> *list);

/** @return A new instance of the receiver's class, with the userInfo contents merged. */
@property (nonnull, nonatomic, readonly) id<PKTKusari> (^merge)(NSDictionary *userInfo);

/** @return a new instance of the receiver's class, with the value removed for the provided key */
@property (nonnull, nonatomic, readonly) id<PKTKusari> (^removeValueForKey)(id<NSCopying> _Nullable key);

/** @return a value from the receiver's userInfo object that matches the provided key. */
@property (nonnull, nonatomic, readonly) id (^value)(NSString *_Nonnull key);

/** @return A new instance of the reciever's class, which the item appended. 
 @note If the item is nil, the receiver will be returned. */
@property (nonnull, nonatomic, readonly) id <PKTKusari> (^append)(id<PKTListDiffable> _Nullable);

/** @return A new instance of the reciever's class, which the item is removed.
 @note If the item is nil, the receiver will be returned. */

@property (nonnull, nonatomic, readonly) id <PKTKusari> (^drop)(id<PKTListDiffable> _Nullable);
/** @return  the receiver's uniqueID is identical to the provided kusari, the receiver; otherwise, the subject of comparison.
 @note Use this function where the receiver should be replaced if the candidate represents a different unique value. */

@property (nonnull, nonatomic, readonly) id<PKTKusari> (^reflect)(id<PKTKusari>);

/** Compare a given value against the value stored against that key in the receiver's userInfo object. */
@property (nonnull, nonatomic, readonly) BOOL (^compareMember)(id<NSCopying> _Nonnull key, id<NSObject> value);

/** @return a copy of the receiver, where the original has been replaced by its substitute */
@property (nonnull, nonatomic, readonly) id<PKTKusari> (^replace)(id<PKTListDiffable> original, id<PKTListDiffable> replacement);

- (id _Nullable)objectForKeyedSubscript:(id<NSCopying>)key;

@end

/**  PKTKusariContainer is a PKTKusariSubclass that wraps a list of PKTKusari objects. */

@protocol PKTKusariContainer <PKTKusari>

@property (nonnull, nonatomic, readonly, copy) NSOrderedSet<id<PKTKusari>> *list;

/** @return a copy of the receiver, where the original has been replaced by its substitute */
@property (nonnull, nonatomic, readonly) id<PKTKusariContainer> (^replace)(id<PKTKusari> original, id<PKTKusari> replacement);

/** @return the PKTKusari element of the receiver's list with the matching uniqueID */
@property (nonnull, nonatomic, readonly) id<PKTKusari> (^child)(NSString *_Nonnull uniqueID);

/** @return the index of the PKTKusari element with the matching uniqueID from the receiver's list */
@property (nonnull, nonatomic, readonly) NSInteger (^index)(NSString *_Nonnull uniqueID);

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

#pragma mark - PKTKusari

@interface PKTKusari <__covariant T:id<PKTListDiffable>> : NSObject <PKTKusari, NSCopying> {
@protected NSOrderedSet<T> *_Nonnull _list;
@protected NSString *_Nonnull _uniqueID;
@protected NSDictionary *_Nullable _userInfo;
@protected NSInteger _type;
}

@property (nonnull, nonatomic, readonly, copy) NSOrderedSet<T> *list;
@property (nonnull, nonatomic, readonly, copy) NSDictionary *userInfo;
@property (nonnull, nonatomic, readonly, copy) NSOrderedSet <PKTKusari<id<PKTListDiffable>>*> *composedList;

@property (nonnull, nonatomic, readonly) PKTKusari<PKTListDiffable> * (^mapped)(id<PKTListDiffable> (^mapped)(T obj));

@property (nonnull, nonatomic, readonly) PKTKusari<PKTListDiffable> * (^filtered)(BOOL (^filter)(T obj));

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^join)(NSOrderedSet<T> *list);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^merge)(NSDictionary *userInfo);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^removeValueForKey)(id<NSCopying> _Nullable key);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^append)(T);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^prepend)(T);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^drop)(T);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^replace)(T original, T replacement);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^reflect)(PKTKusari <T> *_Nonnull);

@property (nonnull, nonatomic, readonly) NSInteger (^indexOf)(T _Nonnull obj);

@property (nonnull, nonatomic, readonly) BOOL (^compareMember)(id<NSCopying> _Nonnull key, id<NSObject> value);

- (id _Nullable)objectForKeyedSubscript:(id<NSCopying>)key;

- (T)objectAtIndexedSubscript:(NSUInteger)idx;

PKTKusari * PKTKusariCreate(NSString *_Nonnull uniqueID, NSInteger type);

- (instancetype)initWithIdentifier:(NSString *_Nonnull)uniqueID
                              type:(NSInteger)type
                          userInfo:(NSDictionary *_Nullable)userInfo
                              list:(NSOrderedSet<id<PKTListDiffable>> *_Nullable)list;

@end

@interface PKTKusariContainer <__covariant T:id<PKTKusari>> : PKTKusari <PKTKusariContainer>

@property (nonnull, nonatomic, readonly, copy) NSOrderedSet<T> *list;
@property (nonnull, nonatomic, readonly, copy) NSDictionary *userInfo;
@property (nonnull, nonatomic, readonly, copy) NSOrderedSet <PKTKusari<id<PKTListDiffable>>*> *composedList;

@property (nonnull, nonatomic, readonly) PKTKusariContainer <T> * (^join)(NSOrderedSet<T> *list);

@property (nonnull, nonatomic, readonly) PKTKusariContainer <T> * (^merge)(NSDictionary *userInfo);

@property (nonnull, nonatomic, readonly) PKTKusari <T> * (^removeValueForKey)(id<NSCopying> _Nullable key);

@property (nonnull, nonatomic, readonly) PKTKusariContainer <T> * (^append)(T);

@property (nonnull, nonatomic, readonly) PKTKusariContainer <T> * (^drop)(T);

@property (nonnull, nonatomic, readonly) PKTKusariContainer <T> * (^replace)(T original, T replacement);

@property (nonnull, nonatomic, readonly) PKTKusariContainer <T> * (^reflect)(PKTKusariContainer <T> *_Nonnull);

@property (nonnull, nonatomic, readonly) T (^child)(NSString *_Nonnull uniqueID);

@property (nonnull, nonatomic, readonly) NSInteger (^index)(NSString *_Nonnull uniqueID);

- (T)objectAtIndexedSubscript:(NSUInteger)idx;

PKTKusariContainer * PKTKusariContainerCreate(NSString *_Nonnull uniqueID, NSInteger type);

@end

@interface NSOrderedSet (PKTKusari)

@property (nonnull, nonatomic, readonly) NSOrderedSet * (^joined)(NSOrderedSet *set);
@property (nonnull, nonatomic, readonly) NSOrderedSet * (^dropped)(id obj);
@property (nonnull, nonatomic, readonly) NSOrderedSet * (^mapped)(PKTMapBlock block);
@property (nonnull, nonatomic, readonly) NSOrderedSet * (^filtered)(BOOL(^filtered)(id obj));
@property (nonnull, nonatomic, readonly) NSOrderedSet *_Nonnull (^flatMapped)(PKTMapFunc block);

@end

@interface NSMutableOrderedSet (PKTKusari)

@property (nonnull, nonatomic, readonly) NSMutableOrderedSet * (^join)(NSOrderedSet *set);
@property (nonnull, nonatomic, readonly) NSMutableOrderedSet * (^drop)(id toDrop);
@property (nonnull, nonatomic, readonly) NSMutableOrderedSet * (^map)(PKTMapBlock block);
@property (nonnull, nonatomic, readonly) NSMutableOrderedSet * (^filtered)(BOOL(^filter)(id obj));
@property (nonnull, nonatomic, readonly) NSMutableOrderedSet *_Nonnull (^flatMap)(PKTMapFunc block);

@end


NS_ASSUME_NONNULL_END
