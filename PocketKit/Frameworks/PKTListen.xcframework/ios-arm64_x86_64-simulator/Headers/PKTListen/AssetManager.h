//
//  AssetManager.h
//  RIL
//
//  Created by Nathan Weiner on 10/24/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTSharedEnums.h"

NS_ASSUME_NONNULL_BEGIN

@interface AssetManager : NSObject

@property (nonatomic, copy) NSString *PATH_PREFIX_NAME;
@property (nonatomic, copy) NSString *DEFAULT_FOLDER_NAME;
@property (nonatomic, copy) NSString *PAGES_FOLDER_NAME;
@property (nonatomic, copy) NSString *ASSETS_FOLDER_NAME;
@property (nonatomic, copy) NSString *TEMP_FOLDER_NAME;
@property (nonatomic, copy) NSString *SESSION_FOLDER_NAME;
@property (nonatomic, copy) NSString *PATH_RIL;
@property (nonatomic, copy) NSString *PATH_CACHE;
@property (nonatomic, copy) NSString *PATH_PAGES;
@property (nonatomic, copy) NSString *PATH_ASSETS;
@property (nonatomic, copy) NSString *PATH_TEMP;
@property (nonatomic, copy) NSString *PATH_TEMP_SESSION;
@property (nonatomic, assign) int ROOT_DIRECTORY;
@property (nonatomic, assign) BOOL usesPrefix;
@property (nonatomic, assign) RILCheck offlinePathHadToBeCreated;

+ (AssetManager *)appCacheManager;
+ (AssetManager *)generalManager;
+ (NSString *)incrementOfflinePrefix;

- (AssetManager *)initAndCheckForOfflinePath:(BOOL)checkForOfflinePath;
- (BOOL)setupPaths:(BOOL)checkForOfflinePath;
- (BOOL)assetExists:(NSString *)path;
- (NSString *)cleanPathName:(NSString *)path;
- (NSString *)folderPathForUniqueId:(NSNumber *)uniqueId;
- (NSString *)pathForWeb:(NSNumber *)uniqueId mime:(NSString *)mimeType;
- (NSString *)pathForText:(NSNumber *)uniqueId;
- (NSString *)folderPathForTempURL:(NSURL *)url;
- (void)removeFolderForUniqueIdInThread:(NSNumber *)uniqueId;
- (void)removeFolderForUniqueId:(NSNumber *)uniqueId;
- (void)removeAssetDomain:(NSString *)assetDomain;

#pragma mark -

- (BOOL)copyResource:(NSString *)resource toPath:(NSString *)path;
- (BOOL)copyResource:(NSString *)resource toPath:(NSString *)path replace:(BOOL)replace;
- (BOOL)copyFile:(NSString *)file toPath:(NSString *)path replace:(BOOL)replace;
- (BOOL)copyBundleResourceToDocuments:(NSString *)resource;
- (BOOL)copyBundleResourceToDocuments:(NSString *)resource replace:(BOOL)replace;
- (BOOL)copyBundleResourceToSharedContainer:(NSString *)resource replace:(BOOL)replace;

- (nullable NSURL *)pathByCreatingTemporaryFileForData:(NSData *)data withFilename:(NSString *)filename;

+ (NSString *)extensionForMimeType:(NSString *)mime;

#pragma mark -

- (void)clearOldCaches;
- (void)clearTemp;

@end

NS_ASSUME_NONNULL_END
