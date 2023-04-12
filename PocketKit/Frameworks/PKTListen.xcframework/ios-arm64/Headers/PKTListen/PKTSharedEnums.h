//
//  Enums.h
//  RIL
//
//  Created by Nathan Weiner on 10/25/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

typedef enum {
    RILNotChecked = 0,
    RILCheckedAndWasTrue = 1,
    RILCheckedAndWasFalse = -1
} RILCheck;

typedef enum {
	ReadItLaterNotifyOnErrorNever = 0,
	ReadItLaterNotifyOnErrorAlways,
	ReadItLaterNotifyOnErrorMajorOnly	// only for errors like maintance or rate limit
} ReadItLaterNotifyOnError;

typedef enum : NSInteger {
    RILViewNone = 0,
    RILViewText = 1,
    RILViewWeb = 2,
    RILViewVideo = 3,
    RILViewImage = 4,
    RILViewPremium = 99
} RILViewType;

typedef enum {
	ItemIsNotOffline = 0,
	ItemIsOffline = 1,
	ItemIsNotOfflineAndFailedLastTime = -1,
	ItemIsNotOfflineAndIsInvalid = -2
} ItemOfflineStatus;

typedef enum {
    ItemMayBeArticle = -1,
    ItemIsArticle = 1,
    ItemIsNotArticle = 0
} ItemArticleStatus;

typedef enum {
    ItemMayBeVideo = -1,
    ItemIsVideo = 1,
    ItemIsNotVideo = 0
} ItemVideoStatus;

typedef enum {
    ItemMayBeImage = -1,
    ItemIsImage = 1,
    ItemIsNotImage = 0
} ItemImageStatus;

typedef enum {
    ItemStatusUnread = 0,
    ItemStatusArchive = 1,
    ItemStatusDelete = 2,
    ItemStatusSharedPending = 3,
    ItemStatusNotInList = 6
} ItemStatus;

typedef enum {
	OfflineQueuePriorityNormal = NSOperationQueuePriorityLow,
	OfflineQueuePriorityHigh = NSOperationQueuePriorityNormal,
	OfflineQueuePrioritySpeedQueue = NSOperationQueuePriorityHigh,
	OfflineQueuePrioritySpeedQueueHigh = NSOperationQueuePriorityVeryHigh
} OfflineQueuePriority;

typedef enum
{
    AddedOfflineActionItemWasNotTried,
	AddedOfflineActionItemWasNotAdded,
	AddedOfflineActionItemAddedToQueue,
	AddedOfflineActionItemWasAlreadyInQueue
} AddedOfflineAction;

typedef enum
{
    RILSyncNotCancelled,
    RILSyncCancelled,
    RILSyncRestarted
} RILSyncCancelType;

typedef enum
{
	MetaTweetId = 1,
	MetaTweetText = 2,
	MetaTweetTime = 3,
	MetaTweetUserHandle = 4,
	MetaTweetUserName = 5,
	MetaTweetUserImageUrl = 6,
	MetaTweetDownloading = 7,
	MetaTweetErrorDownloading = 8,
	MetaTweetLinks = 9,
	MetaTweetRawText = 10,
	MetaTweetEntities = 11,
	MetaTweetRetweeted = 12,
	MetaTweetFavorited = 13
} MetaId;

typedef enum
{
    RILChangeShouldNotSendNotification,
    RILChangeShouldSendListNotification,
    RILChangeShouldSendItemNotification
} RILChangeShouldNotification;

// If add an entry to this enum also add it to the actionIdForName function in PKTFunctions.m
typedef enum 
{
    ACTION_ADD = 1,
    ACTION_READD = 15,
    ACTION_OPENED_ARTICLE = 2,
    ACTION_OPENED_WEB = 13,
    ACTION_OPENED_VIDEO = 17,
    ACTION_OPENED_IMAGE = 43,
    ACTION_ARCHIVE = 3,
    ACTION_FAVORITE = 4,
    ACTION_UNFAVORITE = 5,
    ACTION_DELETE = 6,
    ACTION_ADD_TAGS = 7,
    ACTION_REPLACE_TAGS = 8,
    ACTION_REMOVE_TAGS = 9,
    ACTION_CLEAR_TAGS = 11,
    ACTION_RENAME_TAG = 10,
    ACTION_DELETE_TAG = 14,
    ACTION_SCROLLED = 12,
    ACTION_ADD_LIST_META = 16,
    ACTION_OPENED_APP = 18,
    ACTION_CLOSED_APP = 19,
    ACTION_LOGGED_OUT = 20,
    ACTION_PAGE_VIEW = 24,
    ACTION_SHARED_TO = 27,
    ACTION_SHARE_IGNORED = 29,
    ACTION_SHARE_BLOCKED = 30,
    ACTION_SHARE_ADDED = 31,
    ACTION_LIKED = 32,
    ACTION_UNLIKED = 33,
    ACTION_COMMENT_ADDED = 34,
    ACTION_COMMENT_DELETED = 35,
    ACTION_SHARE_VIEWED = 40,
	ACTION_REGISTER_PUSH = 41,
	ACTION_DEREGISTER_PUSH = 42,
	ACTION_TWEET_REPLIED = 44,
	ACTION_TWEET_RETWEETED = 45,
	ACTION_TWEET_FAVORITED = 46,
	ACTION_FRIEND_BLOCKED = 49,
	ACTION_FRIEND_UNBLOCKED = 50,
    ACTION_SAVED_FROM_CLIPBOARD = 52,
    ACTION_LEFT_ITEM = 55,
    ACTION_START_LISTEN = 39,
    ACTION_STOP_LISTEN = 58,
    ACTION_REWIND_LISTEN = 59,
    ACTION_FAST_FORWARD_LISTEN = 60,
    ACTION_ITEM_IMPRESSION = 61,
    ACTION_GROUP_OPEN = 62,
    ACTION_HIGHLIGHTS_IMPRESSION = 63,
    ACTION_RECENT_SEARCH = 64,
    ACTION_REFRESH_LIBRARY = 65,
    ACTION_SEARCH = 66,
    ACTION_PAGE_VIEW_WT = 67,
    ACTION_REGISTER_SOCIAL_ACCOUNT = 73,
    ACTION_DEREGISTER_SOCIAL_ACCOUNT = 74,
    ACTION_SHARE_POST = 75,
    ACTION_FOLLOW_USER = 76,
    ACTION_UNFOLLOW_USER = 77,
    ACTION_POST_LIKE = 80,
    ACTION_POST_REPOST = 81,
    ACTION_FEED_ITEM_IMPRESSION = 86,
    ACTION_REPORT_FEED_ITEM = 87,
    ACTION_POST_DELETE = 88,
    ACTION_FOLLOW_ALL_USERS = 93,
    ACTION_OPENED_LIST = 94,
    ACTION_OPENED_FEED = 95,
    ACTION_OPENED_NOTIFICATIONS_VIEW = 96,
    ACTION_OPENED_PROFILE = 97,
    ACTION_POST_REMOVE_LIKE = 99,
    ACTION_POST_REMOVE_REPOST = 100,
    ACTION_NOTIFICATION_TRIGGERED = 101,
    ACTION_NOTIFICATION_PUSH_SENT = 102,
    ACTION_NOTIFICATION_PUSH_DELIVERED = 103,
    ACTION_NOTIFICATION_PUSH_PUBLISHED = 104,
    ACTION_NOTIFICATION_PUSH_ACTION = 105,
    ACTION_NOTIFICATION_PUSH_OPENED = 106,
    ACTION_NOTIFICATION_PUSH_DISMISSED = 107,
    ACTION_NOTIFICATION_IMPRESSION = 108,
    ACTION_NOTIFICATION_ACTION = 109,
    ACTION_NOTIFICATION_OPENED = 110,
    ACTION_LIST_ITEM_IMPRESSION = 111,
    ACTION_LOADED_ITEM = 112,
    ACTION_UPDATE_USER_SETTING = 113,
    ACTION_SHARE_LINK_CLICKED = 114,
    ACTION_SP_IMPRESSION_LOADED = 115,
    ACTION_SP_IMPRESSION_VIEWED = 116,
    ACTION_SP_IMPRESSION_CLICKED = 117,
    ACTION_SP_IMPRESSION_FAILED = 118,
    ACTION_SP_ADD = 119,
    ACTION_SP_OPENED_ARTICLE = 120,
    ACTION_SP_OPENED_WEB = 121,
    ACTION_SP_OPENED_VIDEO = 122,
    ACTION_SP_OPENED_IMAGE = 123,
    ACTION_SP_ARCHIVE = 124,
    ACTION_SP_FAVORITED = 125,
    ACTION_SP_TAGS_ADDED = 126,
    ACTION_SP_TAGS_REPLACED = 127,
    ACTION_SP_SHARED = 128,
    ACTION_SP_LEFT_ITEM = 129,
    ACTION_SP_POST_LIKE = 130,
    ACTION_SP_POST_REPOST = 131,
    ACTION_SP_FEED_ITEM_IMPRESSION = 132,
    ACTION_SP_REPORT_FEED_ITEM = 133,
    ACTION_SP_SHARE_TO_PROFILE = 134,
    ACTION_SP_SHARE_TO_TWITTER = 135,
    ACTION_SP_SHARE_TO_FACEBOOK = 136,
    ACTION_SP_SHARE_LINK_CLICKED = 137,
    ACTION_SP_SP_IMPRESSION_LOADED = 138,
    ACTION_SP_SP_IMPRESSION_VIEWED = 139,
    ACTION_SP_SP_IMPRESSION_CLICKED = 140,
    ACTION_SP_SP_IMPRESSION_FAILED = 141,
    ACTION_ITEMREC_REQUEST = 142,
    ACTION_ITEMREC_IMPRESSION = 143,
    ACTION_ITEMREC_OPEN = 144,
    ACTION_ITEMREC_SAVE = 145,
    ACTION_ITEMREC_REPORT = 146,
    ACTION_GLOBALREC_REQUEST = 147,
    ACTION_GLOBALREC_IMPRESSION = 148,
    ACTION_ITEMREC_TIMEOUT = 149,
    ACTION_LI_IMPRESSION_LOADED = 150,
    ACTION_LI_IMPRESSION_VIEWED = 151,
    ACTION_SYNCED = 152,
    ACTION_GET_NOTIFICATIONS = 153,
    ACTION_UPGRADE_GHOST_ACCOUNT = 154,
    ACTION_OPENED_SYSTEM_WIDGET = 155,
    ACTION_OPENED_HOME = 156,
    ACTION_OPENED_TOPIC = 157,
    ACTION_LOADED_TOPIC = 158,
    ACTION_LAYOUT_IMPRESSION = 159,
    ACTION_SP_IMPRESSION_FILLED = 160,
    ACTION_SP_IMPRESSION_UNFILLED = 161,
    ACTION_OPENED_SEARCH = 162,
    ACTION_SEARCH_SUGGESTION_IMPRESSION = 163,
    ACTION_LOADED_SEARCH = 164,
    ACTION_HIDE_FROM_CURRENTLY_READING = 165,
    ACTION_LOCAL_NOTIFICATION_PUSH_TRIGGERED = 166,
    ACTION_LOCAL_NOTIFICATION_PUSH_OPENED = 167,
    ACTION_ADD_ANNOTATION = 168,
    ACTION_DELETE_ANNOTATION = 169,
    ACTION_REACH_END_LISTEN = 187,
    ACTION_PAUSE_LISTEN = 188,
    ACTION_RESUME_LISTEN = 189,
    ACTION_LISTEN_OPENED = 190,
    ACTION_LISTEN_CLOSED = 191,
    ACTION_REGISTER_PUSH_V2 = 194,
    ACTION_DEREGISTER_PUSH_V2 = 195,
} ActionId;


/// We use id in this case for support on iOS and Mac
typedef void(^PKTImageLoadedBlock)(id image);

typedef enum
{
    PKTNotificationIncomingShare,
    PKTNotificationComment,
	PKTNotificationBlock,
	PKTNotificationNotice
} PKTNotificationType;

typedef enum
{
    PKTSyncResultPending,
    PKTSyncResultFailed,
    PKTSyncResultHadData,
    PKTSyncResultNoData
} PKTSyncResult;


// Background fetch handler
typedef enum {
    PKTBackgroundFetchStateCreated,
    PKTBackgroundFetchStateSyncing,
    PKTBackgroundFetchStateWaitingToDownload,
    PKTBackgroundFetchStateDownloading,
    PKTBackgroundFetchStateFinished
} PKTBackgroundFetchState;
