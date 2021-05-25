//
//  RateCell.m
//  LonelyStation
//
//  Created by zk on 16/9/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RateCell.h"
#import "UIUtil.h"
#import "UICycleImgView.h"
#import "EMTextView.h"
#import "UIImage+Blur.h"


#define CellHeight 80

@interface  RateCell(){
    NSDictionary *_identDict;
}
@property (nonatomic,strong)UICycleImgView *headImgView;
@property (nonatomic,strong)EMLabel *commentLabel;
@property (nonatomic,strong)EMLabel *nameLabel;

@end

@implementation RateCell

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier {
    //自定义
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        //生成视图，根据样式是否需要创建背景
        [self initViewsWithSize:size];
    }
    
    return self;
}

- (UICycleImgView*)headImgView {
    if (!_headImgView) {
        _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(0, 0, 30*kScale, 30*kScale)];
        [self.contentView addSubview:_headImgView];
        [_headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(11*kScale);
            make.top.mas_equalTo(floor(10*kScale));
            make.size.mas_equalTo(CGSizeMake(30*kScale, 30*kScale));
        }];
    }
    return _headImgView;
}


- (EMLabel*)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [EMLabel new];
        [self.contentView addSubview:_nameLabel];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImgView.mas_right).offset(10*kScale);
            make.top.mas_equalTo(self.headImgView);
        }];
        _nameLabel.textColor = RGB(0x51, 0x51, 0x51);
        _nameLabel.font = ComFont(11);
    }
    return _nameLabel;
}


- (EMLabel*)commentLabel {
    if (!_commentLabel) {
        _commentLabel = [EMLabel new];
        [self.contentView addSubview:_commentLabel];
        [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(floor(10*kScale));
            make.width.mas_equalTo(kScreenW-50*kScale);
        }];
        _commentLabel.textColor = RGB(0x51, 0x51, 0x51);
        _commentLabel.font = ComFont(11);
        _commentLabel.numberOfLines = 0;
    }
    return _commentLabel;
}


- (void)initViewsWithSize:(CGSize)size {
    //tag图片
//    CGFloat fImgWH = 42.0f*kScale;
//    CGFloat x = 11.f*kScale;
//    CGFloat y = 17.f*kScale;
    _identDict = @{@"1":Local(@"Secreter"),@"2":Local(@"Voicer"),@"3":Local(@"RoleDefault")};
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
        make.bottom.equalTo(self.commentLabel.mas_bottom).offset(10*kScale);
    }];

    
//    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(x, y, fImgWH, fImgWH)];
//
//    [self.contentView addSubview:_headImgView];
//
//    x = PositionX(_headImgView)+20*kScale;
//    CGFloat width = kScreenW - x - 11 - 28*kScale;
//
//    if (!_nameLabel) {
//        _nameLabel = [[EMLabel alloc] initWithFrame:Rect(x + 4, 10, width, 13)];
//    }
//    [self.contentView addSubview:_nameLabel];
//    _nameLabel.hidden = YES;
//    _nameLabel.textColor = RGB(0x03, 0x29, 0xac);
//    _nameLabel.font = ComFont(11);
//
//    if (!_commentTextView) {
//        _commentTextView = [[EMTextView alloc] initWithFrame:Rect(x, 5, width, CellHeight*kScale - 10)];
//        _commentTextView.text = Local(@"IWantRate");
//    }
//    _commentTextView.frame = Rect(x, 11*kScale, width, CellHeight*kScale - 22*kScale);
//    _commentTextView.textColor = RGB(51,51,51);
//    _commentTextView.backgroundColor = RGB(171,171,171);
//    _commentTextView.font = ComFont(11);
//    _commentTextView.userInteractionEnabled = NO;
//    [self.contentView addSubview:_commentTextView];
//
//    [UIUtil addLineWithSuperView:self.contentView andRect:Rect(0, CellHeight*kScale-0.5, kScreenW, 0.5) andColor:RGB(200,200,200)];
    
    
    
}

- (void)setRateObj:(RateObj *)rateObj {
    _rateObj = nil;
    _rateObj = rateObj;
    if ([rateObj.userId isEqualToString:_user.userID]) {
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:_rateObj.file] placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:_user.gender]]  options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        }];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImgView.mas_right).offset(10*kScale);
            make.top.mas_equalTo(self.headImgView);
            make.height.mas_equalTo(0);
        }];
//        self.nameLabel.text = [NSString stringWithFormat:@"%@:%@",_identDict[_rateObj.userIdentifier],_rateObj.nickName];
    }else{
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.headImgView.mas_right).offset(10*kScale);
            make.top.mas_equalTo(self.headImgView);
        }];
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:_rateObj.file] placeholder:[UIImage imageNamed:[EMUtil getPerHeaderDefaultImgNameUseSelfGender:_user.gender]]  options:YYWebImageOptionShowNetworkActivity completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        }];
        self.nameLabel.text = [NSString stringWithFormat:@"%@:%@",_identDict[_rateObj.userIdentifier],_rateObj.nickName];

    }
    self.commentLabel.text = _rateObj.rateNote;

//    CGFloat x = 73.f*kScale;
//    CGFloat width = kScreenW - x - 11 - 28*kScale;
//    if ([rateObj.userId isEqualToString:_user.userID]) {
//        _commentTextView.frame = Rect(x, 22, width, CellHeight*kScale - 33);
//        self.contentView.backgroundColor = RGB(171, 171, 171);
//        _commentTextView.backgroundColor = RGB(171, 171, 171);
//        _nameLabel.hidden = YES;
//    }else {
//        _nameLabel.hidden = NO;
//        _nameLabel.text = [NSString stringWithFormat:@"%@:%@",_identDict[_rateObj.userIdentifier],_rateObj.nickName];
//        self.contentView.backgroundColor = RGB(171, 171, 171);
//        _commentTextView.backgroundColor = RGB(171, 171, 171);
//        _commentTextView.frame = Rect(x, 22, width, CellHeight*kScale - 33);
//    }
//
//    _commentTextView.text = _rateObj.rateNote;
    
//    self.commentLabel.text = @"这个很不错，真的不错，非常nice，好吧，这是真的很好很好很好很好的这个很不错，真的不错，非常nice，好吧，这是真的很好很好很好很好的";
}

@end
