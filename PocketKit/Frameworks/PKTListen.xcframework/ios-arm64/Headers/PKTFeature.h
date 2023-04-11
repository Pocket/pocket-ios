//
//  PKTFeature.h
//  PKTRuntime
//
//  Created by David Skuza on 9/26/19.
//  Copyright © 2019 Pocket. All rights reserved.
//

#ifndef PKTFeature_h
#define PKTFeature_h

/// An enumeration of possible features that a user can be a part of.
/// This enumeration is then used to fetch a feature from a PKT(Extension)User.
/// This is in an attempt to remove string usage from features, while still being
/// able to use strings as necessary with the utility functions:
/// - NSStringFromPKTFeature()
/// - PKTFeatureFromNSString()
typedef NS_ENUM(NSInteger, PKTFeature) {
    PKTFeatureUnknown
};

/// The key within a store that references the features a user is (not) a part of.
UIKIT_EXTERN NSString *const PKTFeatureKey;

/// Returns an NSString representation of a PKTFeature.
/// When adding a new case to PKTFeature, it is best to append its corresponding
/// result to this function.
NSString * _Nullable NSStringFromPKTFeature(PKTFeature);

/// Returns a PKTRepresentation of an NSString.
/// When adding a new case to PKTFeature, it is best to append its corresponding
/// result to this function.
PKTFeature PKTFeatureFromNSString(NSString *);

#endif /* PKTFeature_h */
