//
//  PKTHandyMacros.h
//  PKTHandyMacros
//
//  Created by Michael Schneider on 9/27/15.
//  Copyright © 2015 mischneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTCoreLogging.h"

// See http://petersteinberger.com/blog/2015/uitableviewcontroller-designated-initializer-woes/
// See https://twitter.com/tapbot_paul/status/609422820137775104

#define PKT_NOT_DESIGNATED_INITIALIZER() PKT_NOT_DESIGNATED_INITIALIZER_CUSTOM(init)
#define PKT_NOT_DESIGNATED_INITIALIZER_WITH_CODER() PKT_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithCoder:(NSCoder *)aDecoder)
#define PKT_NOT_DESIGNATED_INITIALIZER_WITH_NIB_BUNDLE() PKT_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithNibName:(NSString *_Nullable)nibNameOrNil bundle:(NSBundle *_Nullable)nibBundleOrNil)
#define PKT_NOT_DESIGNATED_INITIALIZER_WITH_STYLE() PKT_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithStyle:(UITableViewStyle)style)
#define PKT_NOT_DESIGNATED_INITIALIZER_WITH_FRAME() PKT_NOT_DESIGNATED_INITIALIZER_CUSTOM(initWithFrame:(CGRect)frame)

#define PKT_NOT_DESIGNATED_INITIALIZER_CUSTOM(initName) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wobjc-designated-initializers\"") \
- (instancetype)initName \
{ do { \
    NSAssert2(NO, @"%@ is not the designated initializer for instances of %@.", NSStringFromSelector(_cmd), NSStringFromClass([self class])); \
    return nil; \
_Pragma("pragma clang diagnostic pop") \
} while (0); } \

// Prevent warning: performSelector may cause a leak because its selector is unknown

#define PKTSurpressPerformSelectorLeakWarning(code)                         \
    _Pragma("clang diagnostic push")                                        \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")     \
    code;                                                                   \
    _Pragma("clang diagnostic pop")



// See https://github.com/ResearchKit/ResearchKit/blob/9c75263ac5d96ae88bbc6a73c56d43952882affa/ResearchKit/Common/ORKDefines_Private.h#L40

#ifndef PKTDynamicCast
#define PKTDynamicCast(x, c) ((c *) ([(id)(x) isKindOfClass:[c class]] ? x : nil))
#endif

// If the value is a string return the string otherwise return an empty string

#define PKTSafeString(A)  ({ __typeof__(A) __a = (A); __a ? __a : @""; })

// If value conforms to protocol, cast to that protocol; otherwise return nil.

#define PKTDynamicConform(x, p) ((id<p>) ([x conformsToProtocol:@protocol(p)] ? x : nil))

// Safely extract a keyed value from a JSON object. If the JSON object is not a dictionary, it will return nil; if the value is NSNull, it will return nil
#define PKTNormalizedValueForKey(d, k) ((PKTDynamicCast(d, NSDictionary)[k] && ![PKTDynamicCast(d, NSDictionary)[k] isEqual:[NSNull null]]) ? PKTDynamicCast(d, NSDictionary)[k] : nil)

/**
 Safely extract and cast a value from a JSON dictionary:
 If the JSON object is nil, returns nil.
 If the JSON object is not a dictionary, returns nil.
 If the JSON dictionary does not have a value for the key, returns nil.
 If the JSON dictionary's value for the key is NSNull, returns nil.
 If the JSON dictionary's value for the key is not of the provided class, returns nil.
 */

#define PKTCastedValueForKey(d, k, c) PKTDynamicCast(PKTNormalizedValueForKey(d, k), c)

#define PKTSetCastedValueForKey(d, k, c, o) ({ \
    BOOL success = NO; \
    NSMutableDictionary <id, id> *userInfo = nil; \
    if ((userInfo = PKTDynamicCast(d, NSMutableDictionary))) { \
        id value = nil; \
        if ((value = PKTDynamicCast(o, c))) { \
            userInfo[k] = value; \
            success = YES; \
        } \
    } \
    success; \
})

// See: https://gist.github.com/cdzombak/93adfdc3f55c7f8299cd

#define as_checked(EXPR, KLASS) ({ id _obj = EXPR; NSCAssert([_obj isKindOfClass:[KLASS class]], @"Cannot cast %@ to %@", NSStringFromClass([_obj class]), NSStringFromClass([KLASS class])); _obj; })

#define as_option(EXPR, KLASS) ({ id _obj = EXPR; if (![_obj isKindOfClass:[KLASS class]]) _obj = nil; _obj; })

#define lazy_get(TYPE, NAME, VALUE) \
@synthesize NAME = _##NAME; \
- (TYPE)NAME { if (!_##NAME) _##NAME = (VALUE); return _##NAME; }



// See: https://gist.github.com/CraigSiemens/bcdefff3880c508ad2b1

// VARIABLE must be a variable declaration (NSString *foo)
// VALUE is what you are checking is not nil
// WHERE is an additional BOOL condition

#define iflet(VARIABLE, VALUE) \
    ifletwhere(VARIABLE, VALUE, YES)

#define ifletwhere(VARIABLE, VALUE, WHERE) \
    for (BOOL b_ = YES; b_ != NO;) \
        for (id obj_ = (VALUE); b_ != NO;) \
            for (VARIABLE = (obj_ ?: (VALUE)); b_ != NO; b_ = NO) \
                if (obj_ != nil && (WHERE))

// Called just like the swift verstion
// guard(1 < 2) else {
//     return
// }

#define guard(CONDITION) \
    if (CONDITION) {}

#define guardletwhere(VARIABLE, VALUE, WHERE) \
    ifletwhere(VARIABLE, VALUE, WHERE) {}



// Supply a list of arguments, it'll pick the first one that is not or break if it finds an NSNull. It returns the first value that is not NSNull or nil or returns nil if NSNull was found

#define PKTAny(...) _PKTAny(__VA_ARGS__, [NSNull null], nil)
static inline id _PKTAny(id firstObject, ...) {
    va_list args;
    va_start(args, firstObject);
    id obj = firstObject;
    
    while (obj == nil || obj == [NSNull null]){
        if (obj == [NSNull null]) {
            break;
        }
        
        obj = va_arg(args, id);
    }
    va_end(args);
    
    return (obj == [NSNull null] ? nil : obj);
}



// See: https://gist.github.com/cdzombak/844e887ed4bdb933a905

#define PKTWeak(v) __weak __typeof((v))
#define PKTStrong(v) __strong __typeof((v))



// See https://gist.github.com/bsneed/5980089 or https://gist.github.com/literator/9184313

/**
 The __deprecated__ macro saves a little bit of typing around marking classes and methods as deprecated.
 It also provides a compile-time warning which can be used to direct developers elsewhere.
 
 Example 1: Methods
 
    @interface SDLocationManager: CLLocationManager <CLLocationManagerDelegate>
    + (SDLocationManager *)instance;
    - (void)startUpdatingLocation __deprecated__("Use the withDelegate versions of this method");
    - (void)stopUpdatingHeading __deprecated__("Use the withDelegate versions of this method");
    @end
 Example 2: Object interface
    __deprecated__("Use CLGeocoder instead.")
    @interface SDGeocoder : NSObject
    - (id)initWithQuery:(NSString *)queryString apiKey:(NSString *)apiKey;
    @end
 
 Example 3: Formal protocol
 
    __deprecated__("Use CLGeocoder instead.")
    @protocol SDGeocoderDelegate
    - (void)geocoder:(SDGeocoder *)geocoder didFailWithError:(NSError *)error;
    - (void)geocoder:(SDGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark;
    @end
 */

#define __deprecated__(s) __attribute__((deprecated(s)))

/**
 @weakify, @unsafeify and @strongify are loosely based on EXTobjc's implementation with some subtle
 differences.  The main change here has been to reduce the amount of macro-foo to something more
 understandable.  The calling pattern has also changed.  EXTobjc's @weakify for example accepts a
 variable argument list, which it will in turn generate weak shadow vars for all the items in the arg
 list.
 
 This version makes the weak designation a little more implicit by only accepting 1 variable per call.
 A second version of this macro (with the same name) allows it to be used outside of the context of a 
 block.  This can be useful when dealing with delegates, datasources, IBOutlets, etc that are marked
 as weak or strong.
 */

/**
 @weakify(existingStrongVar)
 
    Creates a weak shadow variable called _existingStrongVar_weak which can be later made strong again
    with #strongify.
 
    This is typically used to weakly reference variables in a block, but then ensure that
    the variables stay alive during the actual execution of the block (if they were live upon
    entry)
 
    Example:
    
        @weakify(self);
        [object doSomethingInBlock:^{
            @strongify(self);
            [self doSomething];
        }];
 
 @weakify(existingStrongVar, myWeakVar)
 
    Creates a weak shadow variable of existingStrongVar and gives it the name myWeakVar.  This is useful
    outside of blocks where a weak reference might be needed.
 */

#define weakify(...) \
    try {} @finally {} \
    macro_dispatcher(weakify, __VA_ARGS__)(__VA_ARGS__)

/**
 Like #weakify, but uses __unsafe_unretained instead.
 */

#define unsafeify(...) \
    try {} @finally {} \
    macro_dispatcher(unsafeify, __VA_ARGS__)(__VA_ARGS__)

/**
 @strongify(existingWeakVar)
    Redefines existingWeakVar to a strong variable of the same type.  This is typically used to redefine
    a weak self reference inside a block.
    Example:
        @weakify(self);
        [object doSomethingInBlock:^{
            @strongify(self);
            [self doSomething];
        }];
 @strongify(existingWeakVar, myStrongVar)
    Creates a strong shadow variable of existingWeakVar and gives it the name myStrongVar.  This is useful
    outside of blocks where a strong reference might be needed.
 
    Example:
 
        @strongify(self.delegate, myDelegate);
        if (myDelegate && [myDelegate respondsToSelector:@selector(someSelector)])
            [myDelegate someSelector];
 */

#define strongify(...) \
    try {} @finally {} \
    macro_dispatcher(strongify, __VA_ARGS__)(__VA_ARGS__)


/****** It's probably best not to call macros below this line directly. *******/

// Support bits for macro dispatching based on parameter count.

#define va_num_args(...) va_num_args_impl(__VA_ARGS__, 5,4,3,2,1)
#define va_num_args_impl(_1,_2,_3,_4,_5,N,...) N

#define macro_dispatcher(func, ...) macro_dispatcher_(func, va_num_args(__VA_ARGS__))
#define macro_dispatcher_(func, nargs) macro_dispatcher__(func, nargs)
#define macro_dispatcher__(func, nargs) func ## nargs

// Support macros for @strongify.

#define strongify1(v) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    __strong __typeof(v) v = v ## _weak_ \
    _Pragma("clang diagnostic pop")

#define strongify2(v_in, v_out) \
    __strong __typeof(v_in) v_out = v_in \

// Support macros for @weakify.

#define weakify1(v) \
    __weak __typeof(v) v ## _weak_ = v \

#define weakify2(v_in, v_out) \
    __weak __typeof(v_in) v_out = v_in \

// Support macros for @unsafeify.

#define unsafeify1(v) \
    __unsafe_unretained __typeof(v) v ## _weak_ = v \

#define unsafeify2(v_in, v_out) \
    __unsafe_unretained __typeof(v_in) v_out = v_in \
