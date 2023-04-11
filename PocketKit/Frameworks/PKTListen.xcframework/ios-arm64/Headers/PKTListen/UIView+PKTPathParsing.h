//
//  UView+PKTPathParsing.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 6/27/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#pragma mark - UIView (PKTPathParsing)

/** Methods addressed at creating and parsing path strings that represent a view's position in the view hierarchy. */

#ifdef DEBUG
#define PKTHostPathEnabled
#endif

#ifdef DEBUG
#define PKTAppearancePathDebugEnabled
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UIView (PKTPathParsing)

/**
 @return the viewPath of the view (e.g., $PKTNavigationController/UICollectionView/PKTRecommendationInformationView/UILabel)
 */

@property (nullable, nonatomic, readonly) NSString *viewPath;

/**
 @return the expanded (i.e., non-reduced) view path.
 @note This path will include elements excluded from the viewPath method.
 @note This property can be set externally, to create a "fake" view path for purposes of controlling path expression matches.
 */

@property (nullable, nonatomic, readwrite, copy) NSString *expandedViewPath;

/**
 @return the name of this element as included in the view path
 @note This property can be set externally, to create a "fake" view path name for purposes of controlling path expression matches.
 */

@property (nullable, nonatomic, readwrite, copy) NSString *viewPathName;

/** @return YES if the view's position in the tree matches a given path expression. */

- (BOOL)matchesPath:(NSString *)path;

/** Enumerates all views that are currently part of an application's windows' subview trees. */

+ (void)enumerateAll:(nonnull void(^)(UIView *view))block;

/** Enumerates all views in the receiver's subview hiearchy. */

- (void)enumerateAll:(void(^)(UIView *view))block;

#if defined PKTHostPathEnabled

/** Installs the necessary implementations to populate the view's host property. */

+ (void)installHostPathExtensions;

/** The view controller of which this view is assigned to the view property of. */

@property (nullable, nonatomic, readonly, weak) UIViewController *host;

#endif

#if defined PKTAppearancePathDebugEnabled

/**
 @return the UIAppearance nodes currently applied to the given class within the container hierarchy.
 @example PKTTestView.appearancesWithin(@[@"UIWindow", @"UIView"])
 @note This function uses private methods and should never be compiled into production builds
 @note This function takes the container path names in the opposite order of Apple's proxy methods, with the root first, and leaf last
 */

@property (nonnull, nonatomic, readonly, class) NSArray<NSInvocation*> * (^appearancesWithin)(NSArray<NSString*> *containers);

/**
 @return the UIAppearance nodes currently applied to the given class within the container hierarchy.
 @example PKTTestView.appearancesWithin(@[@"UIWindow", @"UIView"])
 @note This function uses private methods and should never be compiled into production builds
 @note This function takes the container path names in the opposite order of Apple's proxy methods, with the root first, and leaf last
 */

@property (nonnull, nonatomic, readonly, class) NSInvocation * (^appearanceInvocationWithin)(NSArray<NSString*> *containers, NSString *selectorName);

#endif

@end

NS_ASSUME_NONNULL_END
