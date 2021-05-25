//
//  MySwipeCard.m
//  ZLSwipeableViewDemo
//
//  Created by Louis on 2018/5/10.
//  Copyright © 2018年 Zhixuan Lai. All rights reserved.
//

#import "MainZLSwipeChildView.h"
#import "Masonry.h"
#import "EMLabel.h"
#import "UIImage+Blur.h"
#import "LonelyStationUser.h"

@interface MainZLSwipeChildView()

@property (nonatomic,strong)UIImageView *headImageView;

@property (nonatomic,strong)EMLabel *sloganLabel;

@property (nonatomic,strong)EMLabel *nameLabel;

@property (nonatomic,strong)EMLabel *ageAndCity;

@property (nonatomic,strong)EMButton *callBtn;

@property (nonatomic,strong)EMButton *chatBtn;

@property (nonatomic,strong)EMButton *listenBtn;

@end


@implementation MainZLSwipeChildView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initViews];
    [self setup];
    return self;
}

- (void)initViews {
    
    CGFloat width =  self.bounds.size.width;
    _headImageView = [UIImageView new];
    [self addSubview:_headImageView];
    _headImageView.frame = CGRectMake(0, 0, width, 275*kScale);
    _headImageView.layer.cornerRadius = 10;
    _headImageView.layer.masksToBounds = YES;
    
    _sloganLabel = [EMLabel new];
    [self addSubview:_sloganLabel];
    _sloganLabel.frame = CGRectMake(0,CGRectGetMaxY( _headImageView.frame)-28*kScale, width, 16*kScale);
    _sloganLabel.textColor = [UIColor whiteColor];
    _sloganLabel.font = BoldFont(16*kScale);
    _sloganLabel.textAlignment = NSTextAlignmentCenter;
    
    _nameLabel = [EMLabel new];
    [self addSubview:_nameLabel];
    _nameLabel.frame = CGRectMake(0, CGRectGetMaxY(_headImageView.frame)+19*kScale, width, 20*kScale);
    _nameLabel.font = BoldFont(20*kScale);
    _nameLabel.textColor = RGB(27, 27, 27);
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    
    
    _ageAndCity = [EMLabel new];
    [self addSubview:_ageAndCity];
    _ageAndCity.frame = CGRectMake(0, CGRectGetMaxY(_nameLabel.frame)+19*kScale, width, 15*kScale);
    _ageAndCity.font = ComFont(15*kScale);
    _ageAndCity.textColor = RGB(149, 149, 149);
    _ageAndCity.textAlignment = NSTextAlignmentCenter;

    EMLabel *label = [EMLabel new];
    [self addSubview:label];
    label.frame = CGRectMake(0, CGRectGetMaxY(_ageAndCity.frame)+18*kScale, width, 15*kScale);
    label.textColor = RGB(145,90,173);
    label.font = ComFont(15*kScale);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = Local(@"OnlineDesp");

   

    _listenBtn = [EMButton new];
    [self addSubview:_listenBtn];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe"] forState:UIControlStateNormal];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe_d"] forState:UIControlStateHighlighted];
    [_listenBtn setImage:[UIImage imageNamed:@"SBTlistenMe_off"] forState:UIControlStateDisabled];
    _listenBtn.frame = CGRectMake(60*kScale, CGRectGetMaxY(label.frame)+17*kScale,39*kScale, 39*kScale);
   

    _callBtn = [EMButton new];
    [self addSubview:_callBtn];
    _callBtn.frame = CGRectMake(CGRectGetMaxX(_listenBtn.frame)+37*kScale,CGRectGetMaxY(label.frame)+17*kScale,39*kScale, 39*kScale);
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall_d"] forState:UIControlStateHighlighted];
    [_callBtn setImage:[UIImage imageNamed:@"SBTcall_off"] forState:UIControlStateDisabled];
    
    _chatBtn = [EMButton new];
    [self addSubview:_chatBtn];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat_d"] forState:UIControlStateHighlighted];
    [_chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateDisabled];
    _chatBtn.frame =  CGRectMake(CGRectGetMaxX(_callBtn.frame)+37*kScale,CGRectGetMaxY(label.frame)+17*kScale,39*kScale, 39*kScale);;

  
    [self layoutIfNeeded];
}


- (void)setup {
    // Shadow
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOpacity = 0.33;
    self.layer.shadowOffset = CGSizeMake(0, 1.5);
    self.layer.shadowRadius = 4.0;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Corner Radius
    self.layer.cornerRadius = 10.0;
}


- (void)setTalkAction:(SEL)selector andTarget:(id)target {
    [_callBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_callBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}


- (void)setListenAction:(SEL)selector andTarget:(id)target {
    [_chatBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_chatBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setListenSelfAction:(SEL)selector andTarget:(id)target {
    [_listenBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_listenBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setBlurPhoto:(BOOL)ret {
    if (ret) {
        _headImageView.image = [_headImageView.image blurredImage:BlurAlpha];
    }else {
        _headImageView.image = [_headImageView.image blurredImage:0];
    }
}


- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath {
    NSString *file = [EMUtil getFileWithUser:lonelyUser];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [self.headImageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (lonelyUser.seenTime.length > 0){
            [self.headImageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
        }else{
            [self setBlurPhoto:YES];
        }
    }];
    
    self.ageAndCity.text = [NSString stringWithFormat:@"%@  %@ - %@",lonelyUser.age,lonelyUser.country,lonelyUser.city];
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@",lonelyUser.nickName];
    self.callBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setTalkAction:@selector(talkAction:) andTarget:target];
    self.chatBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenAction:@selector(listenAction:) andTarget:target];
    
    self.listenBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenSelfAction:@selector(listenSelfAction:) andTarget:target];
    
    self.sloganLabel.text = [lonelyUser.slogan isEqualToString:@""]?Local(@"HaveNoSlogan"):lonelyUser.slogan;
    
    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:lonelyUser.msgCharge]) {
        [self.chatBtn setImage:[UIImage imageNamed:@"SBTchat_d"] forState:UIControlStateNormal];
    }else {
        [self.chatBtn setImage:[UIImage imageNamed:@"SBTchat"] forState:UIControlStateNormal];
    }
    [self setTalkAction:@selector(talkAction:) andTarget:target];
    [self setListenAction:@selector(listenAction:) andTarget:target];
    [self setListenSelfAction:@selector(listenSelfAction:) andTarget:target];
    //判断广播数量是否为0，为0就不能点
    //    if (lonelyUser.recordsSum.intValue == 0) {
    //        [cell.listenBtn setEnabled:NO];
    //    }else {
    //        [cell.listenBtn setEnabled:YES];
    //    }
    
    //判断是否离线，离线的话就不能点，如果在线但接听时间不在允许范围之内，不能接，弹出相应的提示，只有在线而且接听时间在允许范围之内，才能接
    //        如果online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’N’，   紅框處顯示亮的話筒。
    //        如果 online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’Y’，紅框處顯示暗的話筒。
    //        如果 online=’Y’，identity=’1’ or ‘2’，不管OpStat和ConnectStat，紅框處一律顯示暗的話筒。
    //        如果online=’N’，紅框處一律都顯示暗的話筒。
    if ([lonelyUser.allowTalk intValue] == 1) {
        if (lonelyUser.isOnLine && [lonelyUser.identity isEqualToString:@"3"] && [lonelyUser.optState isEqualToString:@"Y"] && [lonelyUser.connectStat isEqualToString:@"N"]) {
            [self.callBtn setEnabled:YES];
            //如果talkcharge为Y,设置为红色
            if([@"Y" isEqualToString:lonelyUser.talkCharge]) {
                [self.callBtn setImage:[UIImage imageNamed:@"SBTcall_d"] forState:UIControlStateNormal];
            }else {
                [self.callBtn setImage:[UIImage imageNamed:@"SBTcall"] forState:UIControlStateNormal];
            }
        }else {
            [self.callBtn setEnabled:NO];
        }
    }else {
        [self.callBtn setEnabled:NO];
    }
}


@end

