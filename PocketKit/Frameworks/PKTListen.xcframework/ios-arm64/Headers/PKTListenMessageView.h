//
//  PKTListenMessageView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/23/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAbstractMessageView : UIView

@property (nonatomic, readwrite, assign) CGFloat maxWidth;
@property (nonatomic, readwrite, copy, nullable) NSString *messageText;
@property (nonatomic, readwrite, strong, nullable) UIImage *iconImage;
@property (nullable, nonatomic, readonly, strong) UILabel *message;
@property (nullable, nonatomic, readonly, strong) UIImageView *image;
@property (nonnull, nonatomic, readwrite, strong) UIColor *textColor UI_APPEARANCE_SELECTOR;

- (NSDictionary *_Nonnull)textAttributes;

@end

@interface PKTListenWarningMessageView : PKTListenAbstractMessageView

@end

@interface PKTListenActionMessageView : PKTListenAbstractMessageView

@end

@interface PKTListenAnnouncementMessageView : PKTListenWarningMessageView

@end

NS_ASSUME_NONNULL_END
