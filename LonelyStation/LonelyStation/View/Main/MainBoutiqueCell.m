//
//  MainBoutiqueCell.m
//  LonelyStation
//  精品电台
//  Created by 钟铿 on 2018/1/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainBoutiqueCell.h"
#import "LoginStatusObj.h"

@interface MainBoutiqueCell()

@property(nonatomic,strong)NSDictionary *dataDict;

@end



@implementation MainBoutiqueCell


-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initWithSize:(CGSize)frame.size];
    }
    return self;
}

- (void)initWithSize:(CGSize)size {
    _imageView = [[UIImageView alloc] initWithFrame:Rect(0, 0, size.width, size.width)];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
    _imageView.layer.cornerRadius = 5;
    _imageView.layer.masksToBounds = YES;
    
    _playView = [[UIImageView alloc] initWithFrame:Rect(11, size.width - 5 - 20 , 20, 20)];
    _playView.image = [UIImage imageNamed:@"play-arrow"];
    [self.contentView addSubview:_playView];
    
    _seenLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_playView) + 10, _playView.frame.origin.y, size.width - PositionX(_playView) - 10, 20)];
    [_seenLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_seenLabel];

    _nickName = [[EMLabel alloc] initWithFrame:Rect(11, size.width+5, size.width - 11, 40)];
    [_nickName setTextColor:RGB(51, 51, 51)];
    _nickName.numberOfLines = 2;
    [self.contentView addSubview:_nickName];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGestureRecognizer];
}

- (void)tapAction:(UITapGestureRecognizer*)tap {
    if (_cellClickBlock) {
        _cellClickBlock(_dataDict);
    }
}


- (void)setValueWithDict:(NSDictionary*)dict {
    _dataDict = dict.copy;
    NSString *urlStr = dict[@"file"];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([urlStr isEqual:[NSNull null]]) {
        urlStr = @"";
    }
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        [_imageView yy_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
    }else {
        [_imageView yy_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:loginStatus.gender]]];
    }

    NSString *num = dict[@"seen_num"];
    _seenLabel.text = num;
    NSString *nickName = dict[@"nickname"];
    _nickName.text = nickName;
}


@end
