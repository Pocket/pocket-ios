//
//  PKTListenQueueViewController+PKTListenAudibleQueuePresentationContext.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/27/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenQueueViewController.h"
#import "PKTAudibleQueue.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - PKTListenQueueViewController+PKTAudibleQueue

@interface PKTListenQueueViewController (PKTListenAudibleQueuePresentationContext) <PKTListenAudibleQueuePresentationContext>

- (void)pushMessage:(NSString *_Nonnull)messageText;

- (void)pushWarning:(NSString *_Nonnull)warning;

- (void)pushAnnouncement:(NSString *_Nonnull)announcement;

- (void)pushError:(NSError *_Nonnull)error;

- (void)addActionMessageView;

- (void)addAnnouncementMessageView;

- (void)addWarningMessageView;

@end

NS_ASSUME_NONNULL_END
