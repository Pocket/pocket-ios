//
//  PKTListenSettingsViewController.h
//  Listen
//
//  Created by David Skuza on 2/7/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IGListDiffable;
@protocol PKTListenStore;
@class IGListAdapter, IGListSectionController;

typedef NSArray<id<IGListDiffable>>* _Nonnull (^PKTListenSettingsObjectLoader)(IGListAdapter * _Nonnull);
typedef IGListSectionController * _Nonnull (^PKTListenSettingsSectionLoader)(IGListAdapter * _Nonnull, id _Nonnull);

NS_ASSUME_NONNULL_BEGIN

/**
 A reusable view controller that represents one or more views for modifying a user's Listen settings.
 */
@interface PKTListenSettingsViewController : UIViewController

/**
 Initializes a new view controller with a store and section loader.

 @param store The store to load current user settings from.
 @param sectionLoader A block, called when the setcions for the view must be loaded.
 @return A new PKTListenSettingsViewController instance.
 */
- (instancetype)initWithStore:(id<PKTListenStore>)store
                      sectionLoader:(PKTListenSettingsSectionLoader)sectionLoader NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
