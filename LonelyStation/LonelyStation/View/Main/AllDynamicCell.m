//
//  AllDynamicCell.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/4.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "AllDynamicCell.h"

@implementation AllDynamicCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initWithSize:(CGSize)frame.size];
    }
    return self;
}

- (void)initWithSize:(CGSize)size {
    _imageView = [[UIImageView alloc] initWithFrame:Rect(0, 0, size.width, size.width*0.74)];
    [self.contentView addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.layer.cornerRadius = 5;
    _imageView.layer.masksToBounds = YES;
    int lableWidth = (size.width - 10 - 45 - 6*2)/3;
    UIFont *lableFont = ComFont(10);
    
    _hearView = [[UIImageView alloc] initWithFrame:Rect(5, size.width*0.74 - 5 - 15 , 15, 15)];
    _hearView.image = [UIImage imageNamed:@"headphones"];
    [self.contentView addSubview:_hearView];
    
    _hearLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_hearView) + 2, _hearView.frame.origin.y, lableWidth, 15)];
    _hearLabel.font = lableFont;
    [_hearLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_hearLabel];
    
    
    _likeView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_hearLabel) + 2, _hearView.frame.origin.y , 15, 15)];
    _likeView.image = [UIImage imageNamed:@"like_btn_d"];
    [self.contentView addSubview:_likeView];
    
    _likeLabel =[[EMLabel alloc] initWithFrame:Rect(PositionX(_likeView) + 2, _hearView.frame.origin.y, lableWidth, 15)];
    _likeLabel.font = lableFont;
    [_likeLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_likeLabel];
    
    _commentView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_likeLabel) + 2, _hearView.frame.origin.y , 15, 15)];
    _commentView.image = [UIImage imageNamed:@"chat"];
    [self.contentView addSubview:_commentView];
    
    _commentLabel =[[EMLabel alloc] initWithFrame:Rect(PositionX(_commentView) + 2, _hearView.frame.origin.y, lableWidth, 15)];
    _commentLabel.font = lableFont;
    [_commentLabel setTextColor:[UIColor whiteColor]];
    
    [self.contentView addSubview:_commentLabel];
    
   
    
    _titleName = [[EMTopLabel alloc] initWithFrame:Rect(11, size.width*0.74+10, size.width - 11, 20)];
    [_titleName setTextColor:RGB(51, 51, 51)];
    _titleName.font = ComFont(15*kScale);
    _titleName.numberOfLines = 1;
    [self.contentView addSubview:_titleName];
    
    _picView = [[UIImageView alloc] initWithFrame:Rect(11, size.width*0.74+35 , 20*kScale, 20*kScale)];
    _picView.image = [UIImage imageNamed:@"icon_user_lover"];
    [self.contentView addSubview:_picView];
    
    _nickName = [[EMLabel alloc] initWithFrame:Rect(CGRectGetMaxX(_picView.frame)+5, size.width*0.74+35, size.width - CGRectGetMaxX(_picView.frame) - 11, 20)];
    [_nickName setTextColor:RGB(51, 51, 51)];
    [self.contentView addSubview:_nickName];
    
}


- (void)setValueWithObj:(BoardcastObj*)obj {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([obj.imageURL isEqualToString:@""]) {
        [_imageView setImage:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
    }else{
        [_imageView yy_setImageWithURL:[NSURL URLWithString:obj.imageURL] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
    }
    _hearLabel.text = obj.seenNum;
    _commentLabel.text = obj.comments;
    _likeLabel.text = obj.likes;
    _titleName.text = obj.title;
    _nickName.text = obj.nickName;
}


- (void)setNickNameStr:(NSString *)nickNameStr {
    if (_nickName) {
        _nickName.text = nickNameStr;
    }
}


- (void)setValueWithDict:(NSDictionary*)dict {
    NSString *urlStr = dict[@"image"];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_imageView yy_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:user.gender]]];
    
    NSString *num = dict[@"seen_num"];
    _hearLabel.text = num;
    NSString *comments = dict[@"comments"];
    _commentLabel.text = comments;
    NSString *like = dict[@"likes"];
    _likeLabel.text = like;
    _titleName.text = dict[@"title"];
    _nickName.text = dict[@"nickname"];
}



@end
