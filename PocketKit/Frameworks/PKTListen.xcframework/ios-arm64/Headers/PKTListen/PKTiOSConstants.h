//
//  PKTiOSConstants.h
//  RIL
//
//  Created by Michael Schneider on 7/11/15.
//
//

#import <Foundation/Foundation.h>

#pragma mark - Notifications

extern NSString * const PKTAppStyleChangedNotification;
extern NSString * const PKTNotificationsChangedNotification;
extern NSString * const PKTCustomStatusBarTouchedNotification;
extern NSString * const PKTSortChangedNotification;
UIKIT_EXTERN NSString * const PKTDatabaseDidProduceErrorNotification;
UIKIT_EXTERN NSString * const PKTEngineeringAnalyticsEventNotification;

extern NSString * const PKTHasLoggedOutNotification;
extern NSString * const PKTUserMetadataChangedNotification;
extern NSString * const PKTDidAddEmailAliasNotification;
extern NSString * const PKTDidDeleteEmailAliasNotification;
extern NSString * const PKTAvatarServiceFoundMultipleAccountServicesNotification;
extern NSString * const PKTGoogleAuthAttemptNotification;
extern NSString * const PKTUIApplicationStatusBarStyleChangedNotification;


#pragma mark - User Defaults

extern NSString * const PKTQueueSortKey;

extern NSString * const PKTQueueSearchSortKey;

extern NSString * const PKTDeveloperToolsViewControllerDevRevAuthSchemeKey;

extern NSString * const PKTCoreSpotlightIndexerSearchDomainKey;
extern NSString * const PKTCoreSpotlightInitialImportFinishedKey;

extern NSString * const PKTFeedBetaCollectionManagerTappedCTALastTimeKey;
extern NSString * const PKTFeedBetaCollectionManagerDateShownKey;

extern NSString * const PKTHighlightsViewControllerHasSeenHighlightsContentKey;

extern NSString * const PKTItemListBulkEditHandlerHasSeenBulkEditTutorialKey;

extern NSString * const PKTMainItemListViewControllerLastSectionFilterKey;
extern NSString * const PKTMainItemListViewControllerLastSearchFilterKey;
extern NSString * const PKTMainItemListViewControllerLastTagFilterKey;
extern NSString * const PKTMainItemListViewControllerLastContentTypeFilterKey;

extern NSString * const PKTPremiumUpgradedViewControllerUpgradeScreenHasViewedKey;

extern NSString * const PKTNotificationsViewControllerDidIgnorePromptToAddEmailKey;

extern NSString * const PKTSplashScreenPageControllerForceToLogoutKey;

extern NSString * const PKTUpgradedControllerUpgradeScreenLastViewedKey;

extern NSString * const PKTURLAddFromPasteboardHandlerLastClipboardURLHashKey;
extern NSString * const PKTURLAddFromPasteboardHandlerBlockURLPopupKey;

extern NSString * const ReaderEnableContinueReadingKey;
extern NSString * const ReaderAutoOpenBestViewKey;
extern NSString * const ReaderSelectedViewTypeKey;
extern NSString * const ReaderFontSizeKey;
extern NSString * const ReaderTextStyleKey;
extern NSString * const ReaderFontChoiceKey;
extern NSString * const ReaderPreviousNonPremiumFontChoiceKey;
extern NSString * const ReaderMarginKey;
extern NSString * const ReaderMarginValueChangedKey;
extern NSString * const ReaderLineHeightKey;
extern NSString * const ReaderLineHeightValueChangedKey;

extern NSString * const RILAppControllerAllPageStateKeysKey;
extern NSString * const RILAppControllerSettingsKeysKey;

extern NSString * const RILViewControllerRotationLockedPositionKey;

UIKIT_EXTERN NSString * const PKTUserAccessTokenKey;

#pragma mark UserProfileRecommendationCell

extern NSString * const PKTUserProfileRecommendationCellWasShownKey;


#pragma mark Toast

extern NSString * const PKTDidShowShareSuccessToastMessageKey;
extern NSString * const PKTDidShowRecommendEducationToastMessageKey;
extern NSString * const PKTPremiumUpsellToastMessageIsVisibleKey;
extern NSString * const PKTShowNuxNotSavedToastMessageKey;
extern NSString * const PKTShowNuxReaderUpsellToastMessageKey;


#pragma mark PKTBetaFollowingUpgradeNavigationController

extern NSString * const PKTBetaFollowingUpgradeNavigationControllerBeginConnectingSocialServiceKey;


#pragma mark - PKTMainItemListFilterViewController

extern NSString * const PKTItemListFilterSectionIdentifierMyList;
extern NSString * const PKTItemListFilterSectionIdentifierArticles;
extern NSString * const PKTItemListFilterSectionIdentifierVideos;
extern NSString * const PKTItemListFilterSectionIdentifierImages;
UIKIT_EXTERN NSString * const PKTItemListFilterSectionIdentifierContinueReading;
UIKIT_EXTERN NSString * const PKTItemListFilterSectionIdentifierBestOf;
UIKIT_EXTERN NSString * const PKTItemListFilterSectionIdentifierTrending;
UIKIT_EXTERN NSString * const PKTItemListFilterSectionIdentifierHistory;
extern NSString * const PKTItemListFilterSectionIdentifierLongReads;
extern NSString * const PKTItemListFilterSectionIdentifierShortReads;
extern NSString * const PKTItemListFilterSectionIdentifierSharedToMe;
extern NSString * const PKTItemListFilterSectionIdentifierTags;
extern NSString * const PKTItemListFilterSectionIdentifierNoTags;
extern NSString * const PKTItemListFilterSectionIdentifierUntagged;
extern NSString * const PKTItemListFilterSectionIdentifierFavorites;
extern NSString * const PKTItemListFilterSectionIdentifierArchive;
extern NSString * const PKTItemListFilterSectionIdentifierInbox;
extern NSString * const PKTReloadMainItemListViewControllerKey;
UIKIT_EXTERN NSString * const PKTItemListFilterSectionIdentifierHighlights;

#pragma mark - Misc

extern NSString * const PKTSortQueueRelevance;
extern NSString * const PKTSortQueueNewest;
extern NSString * const PKTSortQueueOldest;
UIKIT_EXTERN NSString * const kPKTEngineeringAnalyticsEventName;
UIKIT_EXTERN NSString * const kPKTEngineeringAnalyticsEventInfo;

#pragma mark - PKTPocketNotificationViewController

extern NSString * const PKTPocketNotificationViewControllerRefreshFromPushPocketNotificationsKey;

#pragma mark - PKTUpgradeService

extern NSString * const PKTUpgradeServicePreviousVersionKey;

#pragma mark - NSUserDefaults

UIKIT_EXTERN NSString * const kPKTAppThemeTransitionCurve;
