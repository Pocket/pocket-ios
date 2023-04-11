//
//  PKTiOSEnums.h
//  RIL
//
//  Created by Michael Schneider on 7/12/15.
//
//

#pragma once

typedef enum {
    RILAnimateBack = -1,
    RILAnimateNone = 0,
    RILAnimateForward = 1
} RILAnimateDirection;

typedef enum {
    TransientError,
    TransientInformational,
    TransientDialog
} TransientErrorType;

typedef enum {
    ReaderActionTypeLink,
    ReaderActionTypeImageLink
} ReaderActionType;

typedef enum
{
	ReaderScrollDataPartScrollHeight,
	ReaderScrollDataPartInnerHeight,
	ReaderScrollDataPartScrolled,
	ReaderScrollDataPartNodeIndex,
	ReaderScrollDataPartSection,
    ReaderScrollDataPartPage
} ReaderScrollDataPart;

typedef enum : NSUInteger {
    ReaderOpenSourceUnknown,
    ReaderOpenSourceList,
    ReaderOpenSourceSearch,
    ReaderOpenSourceNotifications,
    ReaderOpenSourceNotification,
    ReaderOpenSourceHandoff,
    ReaderOpenSourceFeed,
    ReaderOpenSourceProfile,
    ReaderOpenSourceContinueReading,
} ReaderOpenSource;

typedef enum {
    PKTMessageActionClicked,
    PKTMessageActionPocketed
} PKTMessageAction;

typedef enum {
    PKTOrientationUnknown = 0,
    PKTOrientationPortrait = 1,
    PKTOrientationLandscapeLeft = 2,
    PKTOrientationPortraitUpsideDown = 3,
    PKTOrientationLandscapeRight = 4
} PKTOrientation;

typedef NS_ENUM(NSInteger, PKTNetworkStatus) {
    PKTNetworkStatusUnknown         = 0,
    PKTNetworkStatusOffline,
    PKTNetworkStatusOnlineWifi,
    PKTNetworkStatusOnlineCellular,
};

typedef enum
{
    PKTFieldTypeStandard, // Title and Subtitle
	PKTFieldTypeStandardContactAutocomplete,
    PKTFieldTypeTextArea, // Show a text view
    PKTFieldTypeItem // Show item information
} PKTFieldType;

typedef enum : NSInteger {
    textFontDefault = 19,
    textFontNormalOld = 15,
    textFontNormal = 18,
    textFontNormalIpadMini = 19
} TextViewFontSize;

typedef enum : NSInteger {
    textFontSansSerif,
    textFontSerif
} TextViewFontType;

typedef enum : NSUInteger {
    textMarginIphoneIncrementDefault = 3,
    textMarginIpadIncrementDefault = 2,
    textMarginMaxIncrementIphone = 6,
    textMarginMaxIncrementIpad = 7
} TextViewMargin;

typedef enum : NSUInteger {
    textLineHeightIncrementDefault = 4,
    textLineHeightMaxIncrement = 13
} TextViewLineHeight;

typedef enum
{
	textAlignJustify,
	textAlignLeft
} TextViewAlignment;

typedef enum :NSUInteger {
    autoNightModeHourStart = 12+8, // 8pm
    autoNightModeHourEnd = 8 // 8am
} AutoNightModeTime;

typedef enum
{
    RILToolbarStyleDefault,
    RILToolbarStyleFlat,
    RILToolbarStyleFlatDark,
    RILToolbarStyleFlatSepia,
    RILToolbarStyleTray,
    RILToolbarStyleTrayDark,
    RILToolbarStyleTraySepia,
    RILToolbarStyleLeftSideMenu,
    RILToolbarStyleLeftSideMenuDark,
    RILToolbarStyleBlack,
	RILToolbarStyleNone
} RILToolbarStyle;

typedef enum
{
    RILToolbarShadowStyleNone,
    RILToolbarShadowStyleDefault,
    RILToolbarShadowStyleCurved
} RILToolbarShadowStyle;

typedef enum
{
    RILButtonBorderNone,
    RILButtonBorderLeft,
    RILButtonBorderRight
} RILButtonBorderStyle;

typedef enum
{
    RILPopoverCarrotPositionUndefined = 0,
    RILPopoverCarrotLeft,
    RILPopoverCarrotMiddle,
    RILPopoverCarrotRight
} RILPopoverCarrotPosition;

typedef enum
{
    RILPopoverCarrotVerticalPositionUndefined = 0,
    RILPopoverCarrotVerticalPositionTop = 10,
    RILPopoverCarrotVerticalPositionBottom = 11
} RILPopoverCarrotVerticalPosition;

typedef enum
{
    RILBarButtonItemTypeTitle,
    RILBarButtonItemTypeTitleNew,
    RILBarButtonItemTypeImage,
    RILBarButtonItemTypeTitleImage,
    RILBarButtonItemTypeTitleSelector,
    RILBarButtonItemTypeImageSelector,
    RILBarButtonItemTypeImageToggle,
    RILBarButtonItemTypeImagePopover,
    RILBarButtonItemTypeBack,
    RILBarButtonItemTypeSpacer,
    RILBarButtonItemTypeImageLeft,
    RILBarButtonItemTypeImageRight,
    
    RILBarButtonItemTypeYellow,
    RILBarButtonItemTypeGray
} RILBarButtonItemType;

typedef enum
{
    RILBarButtonItemSelectedStyleDefault,
    RILBarButtonItemSelectedStyleUseSource
} RILBarButtonItemSelectedStyle;

// Default animation completion block
typedef void (^AnimationCompletionBlock)(BOOL finished);

// Possible layouts of the item list
typedef NS_ENUM(NSUInteger, PKTItemListLayout) {
    PKTItemListLayoutGrid = 0,
    PKTItemListLayoutList = 1
};

// Sections for the item list
typedef NS_ENUM(NSUInteger, PKTItemListViewSection) {
    PKTItemListViewSectionChangeSection = 0,
    PKTItemListViewSectionItems = 1,
    PKTItemListViewSectionNoContentView = 2,
    PKTItemListViewSectionToggleSection = 3
};

typedef NS_ENUM(NSUInteger, PKTSideSwipeCellDirection) {
    PKTSideSwipeCellDirectionNone = 0,
    PKTSideSwipeCellDirectionRight = 1,
    PKTSideSwipeCellDirectionLeft  = 2,
};

typedef NS_ENUM(NSUInteger, PKTItemListViewFilterSection) {
    PKTItemListViewFilterSectionGroup = 0, // Should show only items from Highlights
    PKTItemListViewFilterSectionAll = 1, // Should show items from unread and archive
    PKTItemListViewFilterSectionMyList = 2, // Should show items from my list only
    PKTItemListViewFilterSectionArchive = 3, // Should show items from the archive only
};

typedef NS_ENUM(NSUInteger, PKTItemListViewFilterContentType) {
    PKTItemListViewFilterContentTypeAll = 0, // Should not filter any items with content type
    PKTItemListViewFilterContentTypeArticle = 1, // Should filter list for articles
    PKTItemListViewFilterContentTypeImage = 2, // Should filter list for images
    PKTItemListViewFilterContentTypeVideo = 3, // Should filter list for videos
    PKTItemListViewFilterContentTypeSharedWithMe = 4, // Should filter list for items shared to me
    PKTItemListViewFilterContentTypeLongReads = 5, // Should filter list for long reads
    PKTItemListViewFilterContentTypeShortReads = 6, // Should filter list for short reads
    PKTItemListViewFilterContentTypeHighlightAnnotations = 7, // Should filter list for items with at least 1 highlight annotation
    PKTItemListViewFilterContentTypeContinueReading = 8, // Should filter list for items that are in currently reading (status = 0, is_article = 1, positions[0].time_spent >= 20, positions[0].percent <= 95, sorted by time_updated DESC
    PKTItemListViewFilterContentTypeBestOf = 9, // Should filter list for best of groups
    PKTItemListViewFilterContentTypeTrending = 10, // Should filter list for tending groups
};
