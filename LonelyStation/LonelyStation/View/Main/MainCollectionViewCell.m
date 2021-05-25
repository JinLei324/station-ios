//
//  MainCollectionViewCell.m
//  LonelyStation
//
//  Created by zk on 16/7/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MainCollectionViewCell.h"
#import "UIImage+Blur.h"
#import "LonelyStationUser.h"

@interface MainCollectionViewCell() {
    EMLabel *_statusLabel;
    NSArray *_colorArray;
    NSArray *_statusArray;    
}

@end


@implementation MainCollectionViewCell

- (void)setBlurPhoto:(BOOL)ret {
    if (ret) {
        _imageView.image = [_imageView.image blurredImage:BlurAlpha];
    }else {
        _imageView.image = [_imageView.image blurredImage:0];
    }
}


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initWithSize:(CGSize)frame.size];
        //初始化颜色数组和状态数组
        _colorArray = @[RGB(137,146,147),RGB(125,201,58),RGB(253,60,34),RGB(142,137,9)];
        _statusArray = @[Local(@"OffLine"),Local(@"OnLine"),Local(@"Busy"),Local(@"OnLine")];
    }
    return self;
}

- (void)initWithSize:(CGSize)size {
    //头像是正方形
    _imageView = [[UIImageView alloc] initWithFrame:Rect(0, 0, size.width, size.width)];
//    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
    [_imageView.layer setCornerRadius:15];
    [_imageView.layer setMasksToBounds:YES];
    //添加三个按钮
    CGFloat width = 42 * kScale;
    CGFloat marginX = 17 * kScale;
    CGFloat marginY = (size.width - width - 2);
    CGFloat space = ((size.width - 3 * width - marginX * 2) / 2.f) * kScale;
    _talkBtn = [[EMButton alloc] initWithFrame:Rect(marginX, marginY, width, width) isRdius:YES];
    [_talkBtn setImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
    [_talkBtn setImage:[UIImage imageNamed:@"call-on"] forState:UIControlStateHighlighted];
    [_talkBtn setImage:[UIImage imageNamed:@"call-off"] forState:UIControlStateDisabled];

    
    
    _listenBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_talkBtn) + space, marginY, width, width) isRdius:YES];
    [_listenBtn setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
    [_listenBtn setImage:[UIImage imageNamed:@"message_on"] forState:UIControlStateHighlighted];
    [_listenBtn setImage:[UIImage imageNamed:@"message"] forState:UIControlStateDisabled];
    
    _listenSelfBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(_listenBtn) + space, marginY, width, width) isRdius:YES];
    [_listenSelfBtn setImage:[UIImage imageNamed:@"me"] forState:UIControlStateNormal];
    [_listenSelfBtn setImage:[UIImage imageNamed:@"me"] forState:UIControlStateHighlighted];
    [_listenSelfBtn setImage:[UIImage imageNamed:@"me_off"] forState:UIControlStateDisabled];


    [self.contentView addSubview:_talkBtn];
    [self.contentView addSubview:_listenBtn];
    [self.contentView addSubview:_listenSelfBtn];
        
    //添加在线离线状态
    marginX = 4;
    width = 47 * kScale;
    CGFloat hight = 21 * kScale;
    _statusLabel = [[EMLabel alloc] initWithFrame:Rect(size.width - width - marginX, marginX, width, hight) andConners:15];
    _statusLabel.backgroundColor = _colorArray[0];
//    _statusLabel.text = @"上线";
    _statusLabel.font = ComFont(14 * kScale);
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    _statusLabel.textColor = RGB(0xff, 0xff, 0xff);
    [self.contentView addSubview:_statusLabel];
    UIImageView *picView = [[UIImageView alloc] initWithFrame:Rect(6, size.height - 47 * kScale, 20*kScale, 20*kScale)];
    picView.image = [UIImage imageNamed:@"icon_user_lover"];
    [self.contentView addSubview:picView];
    
    //添加文字
    _roleAndNickLable = [[UILabel alloc] initWithFrame:Rect(8+20*kScale, size.height - 42 * kScale, size.width - 6, 14*kScale)];
    _roleAndNickLable.text = @"角色: 昵称就六个字";
    _roleAndNickLable.textColor = RGB(51, 51, 51);
    _roleAndNickLable.font = ComFont(13*kScale);
    [self.contentView addSubview:_roleAndNickLable];
    
    _personalDesLabel = [[UILabel alloc] initWithFrame:Rect(6, size.height - 24*kScale, size.width - 6, 14*kScale)];
    _personalDesLabel.text = @"心情就是只八个字／城市";
    _personalDesLabel.textColor = RGB(145,90,173);
    _personalDesLabel.font = ComFont(13*kScale);
    [self.contentView addSubview:_personalDesLabel];
}

- (void)setStatus:(StationOnlineStatus)status {
    _status = status;
    //设置上线下线状态和背景颜色
    _statusLabel.text = _statusArray[status];
    _statusLabel.backgroundColor = _colorArray[status];
    

}

- (void)setTalkAction:(SEL)selector andTarget:(id)target {
    [_talkBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_talkBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}


- (void)setListenAction:(SEL)selector andTarget:(id)target {
    [_listenBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_listenBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setListenSelfAction:(SEL)selector andTarget:(id)target {
    [_listenSelfBtn removeTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [_listenSelfBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
}

- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath{
    NSString *file = [EMUtil getFileWithUser:lonelyUser];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]] options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (lonelyUser.seenTime.length > 0){
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:user.gender]]];
        }else{
            [self setBlurPhoto:YES];
        }
    }];
    self.status = lonelyUser.isOnLine;
    
    self.roleAndNickLable.text = [NSString stringWithFormat:@"%@/%@",lonelyUser.nickName,lonelyUser.city];
    self.talkBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setTalkAction:@selector(talkAction:) andTarget:target];
    self.listenBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenAction:@selector(listenAction:) andTarget:target];
    
    self.listenSelfBtn.titStr = [NSString stringWithFormat:@"%d",(int)indexPath.row];
    [self setListenSelfAction:@selector(listenSelfAction:) andTarget:target];
    
    self.personalDesLabel.text = [lonelyUser.slogan isEqualToString:@""]?Local(@"HaveNoSlogan"):lonelyUser.slogan;
    
    if ([lonelyUser.identity isEqualToString:@"2"]) {
        if (lonelyUser.isOnLine && [lonelyUser.connectStat isEqualToString:@"N"]) {
            self.status = StationLoverOnline;
        }else if (lonelyUser.isOnLine && ![lonelyUser.connectStat isEqualToString:@"N"]){
            self.status = StationStatusBusy;
        }else {
            self.status = StationStatusOffline;
        }
    }else {
        if (lonelyUser.isOnLine && [lonelyUser.connectStat isEqualToString:@"N"]) {
            self.status = StationStatusOnline;
        }else if (lonelyUser.isOnLine && ![lonelyUser.connectStat isEqualToString:@"N"]){
            self.status = StationStatusBusy;
        }else {
            self.status = StationStatusOffline;
        }
    }
    
    //如果msgCharge为Y,设置为红色
    if([@"Y" isEqualToString:lonelyUser.msgCharge]) {
        [self.listenBtn setImage:[UIImage imageNamed:@"message_on"] forState:UIControlStateNormal];
    }else {
        [self.listenBtn setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
    }
    //判断是否有自介
    if (lonelyUser.voice.length == 0) {
        [self.listenSelfBtn setEnabled:NO];
    }else {
        [self.listenSelfBtn setEnabled:YES];
    }
    
    //判断是否离线，离线的话就不能点，如果在线但接听时间不在允许范围之内，不能接，弹出相应的提示，只有在线而且接听时间在允许范围之内，才能接
    //        如果online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’N’，   紅框處顯示亮的話筒。
    //        如果 online=’Y’，identity=’3’，OpStat=’Y’，ConnectStat=’Y’，紅框處顯示暗的話筒。
    //        如果 online=’Y’，identity=’1’ or ‘2’，不管OpStat和ConnectStat，紅框處一律顯示暗的話筒。
    //        如果online=’N’，紅框處一律都顯示暗的話筒。
    if ([lonelyUser.allowTalk intValue] == 1) {
        if (lonelyUser.isOnLine && [lonelyUser.identity isEqualToString:@"3"] && [lonelyUser.optState isEqualToString:@"Y"] && [lonelyUser.connectStat isEqualToString:@"N"]) {
            [self.talkBtn setEnabled:YES];
            //如果talkcharge为Y,设置为红色
            if([@"Y" isEqualToString:lonelyUser.talkCharge]) {
                [self.talkBtn setImage:[UIImage imageNamed:@"call-on"] forState:UIControlStateNormal];
            }else {
                [self.talkBtn setImage:[UIImage imageNamed:@"call"] forState:UIControlStateNormal];
            }
        }else {
            [self.talkBtn setEnabled:NO];
        }
    }else {
        [self.talkBtn setEnabled:NO];
    }
}


@end
