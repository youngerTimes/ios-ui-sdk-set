//
//  RCContactCardMessageCell.m
//  RongContactCard
//
//  Created by Sin on 16/8/19.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCContactCardMessageCell.h"
#import "RCContactCardMessage.h"
#import "UIColor+RCCCColor.h"
#import "RCCCUtilities.h"
#import "RCloudImageView.h"
#define Cart_Message_Cell_Height 93
#define Cart_Portrait_View_Width 40


@interface RCContactCardMessageCell ()
@property (nonatomic, strong) NSMutableArray *messageContentConstraint;

//@property (nonatomic, strong) UILabel *typeLabel;     //个人名片的字样 //【源码修改】
//@property (nonatomic, strong) UIView *separationView; //分割线 //【源码修改】
@property(nonatomic,strong) UIImageView *nextImg; //下一个
@property (nonatomic, assign) BOOL isConversationAppear;
@end

@implementation RCContactCardMessageCell

+ (CGSize)sizeForMessageModel:(RCMessageModel *)model
      withCollectionViewWidth:(CGFloat)collectionViewWidth
         referenceExtraHeight:(CGFloat)extraHeight {
    CGFloat messagecontentview_height = Cart_Message_Cell_Height;
    if (messagecontentview_height < RCKitConfigCenter.ui.globalMessagePortraitSize.height) {
        messagecontentview_height = RCKitConfigCenter.ui.globalMessagePortraitSize.height;
    }
    messagecontentview_height += extraHeight;
    //---
//    return CGSizeMake(collectionViewWidth, messagecontentview_height);
    return CGSizeMake(collectionViewWidth, messagecontentview_height + 20); //【源码修改】
    //---
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.messageContentConstraint = [[NSMutableArray alloc] init];
    [self showBubbleBackgroundView:YES];

    //头像imageView
    self.portraitView = [[RCloudImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.portraitView];
    self.portraitView.translatesAutoresizingMaskIntoConstraints = YES;
    self.portraitView.layer.masksToBounds = YES;

    if (RCKitConfigCenter.ui.globalConversationAvatarStyle == RC_USER_AVATAR_CYCLE &&
        RCKitConfigCenter.ui.globalMessageAvatarStyle == RC_USER_AVATAR_CYCLE) {
        self.portraitView.layer.cornerRadius = Cart_Portrait_View_Width/2;
    } else {
        self.portraitView.layer.cornerRadius = 5.f;
    }

    [self.portraitView
        setPlaceholderImage:[RCCCUtilities imageNamed:@"default_portrait_msg" ofBundle:@"RongCloud.bundle"]];

    //昵称label
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    if (@available(iOS 8.2, *)) {
        [self.nameLabel setFont:[UIFont systemFontOfSize:13.f weight:UIFontWeightBold]];
    } else {
        [self.nameLabel setFont:[UIFont systemFontOfSize:13.f]];
    } //【源码修改】
    self.nameLabel.textAlignment = NSTextAlignmentCenter; //【源码修改】
    [self.messageContentView addSubview:self.nameLabel];
    self.messageContentView.layer.cornerRadius = 20;
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.nameLabel.textColor = [RCKitUtility generateDynamicColor:[UIColor colorWithHexString:@"333333" alpha:1] darkColor:[UIColor colorWithHexString:@"ffffff" alpha:0.8]];
    self.nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;

    self.idNumL = [[UILabel alloc]initWithFrame:CGRectZero];
    [self.idNumL setFont:[UIFont systemFontOfSize:12]];
    self.idNumL.textAlignment = NSTextAlignmentCenter;
    self.idNumL.textColor = [RCKitUtility generateDynamicColor:[UIColor colorWithHexString:@"616161" alpha:1] darkColor:[UIColor colorWithHexString:@"ffffff" alpha:0.8]];
    [self.messageContentView addSubview:self.idNumL];

    self.nextImg = [[UIImageView alloc]initWithImage:RCResourceImage(@"icon_next")];
    [self.messageContentView addSubview:self.nextImg];

    //--- 【源码修改】
    //分割线
//    self.separationView = [[UIView alloc] initWithFrame:CGRectZero];
//    self.separationView.backgroundColor =
//        [RCKitUtility generateDynamicColor:[UIColor colorWithHexString:@"ededed" alpha:1]
//                                 darkColor:[UIColor colorWithHexString:@"373737" alpha:1]];
//    self.separationView.translatesAutoresizingMaskIntoConstraints = YES;
//    [self.messageContentView addSubview:self.separationView];

    // typeLabel
//    self.typeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//    self.typeLabel.text = RCLocalizedString(@"ContactCard");
//    self.typeLabel.font = [UIFont systemFontOfSize:12.f];
//    self.typeLabel.textColor = [RCKitUtility generateDynamicColor:[UIColor colorWithHexString:@"939393" alpha:1] darkColor:[UIColor colorWithHexString:@"ffffff" alpha:0.4]];
//    [self.messageContentView addSubview:self.typeLabel];
    //---

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCell:)
                                                 name:@"RCKitDispatchUserInfoUpdateNotification"
                                               object:nil];
}

- (void)updateCell:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfoDic = notification.object;
        NSString *userId = userInfoDic[@"userId"];
        RCContactCardMessage *cardMessage = (RCContactCardMessage *)self.model.content;
        if ([userId isEqualToString:cardMessage.userId]) {
            RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:userId];
            NSString *portraitUri = userInfo.portraitUri;
            NSString *userId = [userInfo.userId componentsSeparatedByString:@"_"].lastObject;
            self.idNumL.text = [NSString stringWithFormat:@"ID：%@",userId];
            [self.portraitView setImageURL:[NSURL URLWithString:portraitUri]];
        }
    });
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    [self beginDestructing];
    [self setAutoLayout];
}

- (void)setAutoLayout {
    RCContactCardMessage *cardMessage = (RCContactCardMessage *)self.model.content;
    if (cardMessage) {
        self.nameLabel.text = cardMessage.name;
        NSString *portraitUri = cardMessage.portraitUri;
        if (portraitUri.length < 1) {
            RCUserInfo *userInfo = [[RCIM sharedRCIM] getUserInfoCache:cardMessage.userId];
            if (userInfo == nil || userInfo.portraitUri.length < 1) {
                if ([[RCIM sharedRCIM]
                            .userInfoDataSource respondsToSelector:@selector(getUserInfoWithUserId:completion:)]) {
                    [[RCIM sharedRCIM]
                            .userInfoDataSource
                        getUserInfoWithUserId:cardMessage.userId
                                   completion:^(RCUserInfo *userInfo) {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           [self.portraitView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
                                           NSString *userId = [userInfo.userId componentsSeparatedByString:@"_"].lastObject;
                                           self.idNumL.text = [NSString stringWithFormat:@"ID：%@",userId];
                                       });
                                   }];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.portraitView setImageURL:[NSURL URLWithString:userInfo.portraitUri]];
                    NSString *userId = [userInfo.userId componentsSeparatedByString:@"_"].lastObject;
                    self.idNumL.text = [NSString stringWithFormat:@"ID：%@",userId];
                });
            }
        } else {
            [self.portraitView setImageURL:[NSURL URLWithString:portraitUri]];
            NSString *userId = [cardMessage.userId componentsSeparatedByString:@"_"].lastObject;
            self.idNumL.text = [NSString stringWithFormat:@"ID：%@",userId];
        }
    }

    self.messageContentView.contentSize = [[self class] sizeOfMessageCell];
    //---
    self.portraitView.center = CGPointMake(50.5, 25); //【源码修改】
    self.portraitView.bounds = CGRectMake(0, 0, Cart_Portrait_View_Width, Cart_Portrait_View_Width);//【源码修改】
//    self.portraitView.frame = CGRectMake(12, 10, Cart_Portrait_View_Width, Cart_Portrait_View_Width);
    //---

    //---
//    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.portraitView.frame)+12, 17.5, 100, 25);
    self.nameLabel.center = CGPointMake(50.5, CGRectGetMaxY(self.portraitView.frame)+15);//【源码修改】
    self.nameLabel.bounds = CGRectMake(0, 0, 101, 25);//【源码修改】
    self.idNumL.center = CGPointMake(50.5, CGRectGetMaxY(self.nameLabel.frame)+5);//【源码修改】
    self.idNumL.bounds = CGRectMake(0, 0, 101, 17);//【源码修改】
    self.nextImg.center = CGPointMake(50.5, CGRectGetMaxY(self.idNumL.frame)+15);//【源码修改】
    self.nextImg.bounds = CGRectMake(0, 0, 16, 16);
    //---



    //【源码修改】
//    self.separationView.frame = CGRectMake(CGRectGetMinX(self.portraitView.frame),CGRectGetMaxY(self.portraitView.frame)+12, self.messageContentView.frame.size.width - 12 * 2, 0.5);

    //【源码修改】
//    self.typeLabel.frame = CGRectMake(CGRectGetMinX(self.portraitView.frame),CGRectGetMaxY(self.portraitView.frame)+16.5, 100, 16.5);
}

- (void)beginDestructing {
    RCContactCardMessage *cardMessage = (RCContactCardMessage *)self.model.content;
    if (self.model.messageDirection == MessageDirection_RECEIVE && cardMessage.destructDuration > 0 &&
        [UIApplication sharedApplication].applicationState != UIApplicationStateBackground &&
        self.isConversationAppear) {
        [[RCIMClient sharedRCIMClient]
            messageBeginDestruct:[[RCIMClient sharedRCIMClient] getMessageByUId:self.model.messageUId]];
    }
}

+ (CGSize)sizeOfMessageCell {
    //---
//    return CGSizeMake([RCMessageCellTool getMessageContentViewMaxWidth], Cart_Message_Cell_Height);
    return CGSizeMake(101, 125); //【源码修改】
    //---
}

@end
