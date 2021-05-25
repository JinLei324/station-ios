//
//  MainDynamicCell.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/1/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainDynamicCell.h"
#import "LoginStatusObj.h"

@implementation MainDynamicCell

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
    [self.contentView addSubview:_imageView];
    _imageView.contentMode = UIViewContentModeScaleToFill;
    _imageView.layer.cornerRadius = 5;
    _imageView.layer.masksToBounds = YES;
    int lableWidth = (size.width - 10 - 45 - 6*2)/3;
    UIFont *lableFont = ComFont(10);
    
    _hearView = [[UIImageView alloc] initWithFrame:Rect(5, size.width - 5 - 15 , 15, 15)];
    _hearView.image = [UIImage imageNamed:@"headphones"];
    [self.contentView addSubview:_hearView];
    
    _hearLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_hearView) + 2, _hearView.frame.origin.y, lableWidth, 15)];
    _hearLabel.font = lableFont;
    [_hearLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_hearLabel];
    
    _commentView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_hearLabel) + 2, _hearView.frame.origin.y , 15, 15)];
    _commentView.image = [UIImage imageNamed:@"chat"];
    [self.contentView addSubview:_commentView];
    
    _commentLabel =[[EMLabel alloc] initWithFrame:Rect(PositionX(_commentView) + 2, _hearView.frame.origin.y, lableWidth, 15)];
    _commentLabel.font = lableFont;
    [_commentLabel setTextColor:[UIColor whiteColor]];

    [self.contentView addSubview:_commentLabel];
    
    _likeView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_commentLabel) + 2, _hearView.frame.origin.y , 15, 15)];
    _likeView.image = [UIImage imageNamed:@"enjoy_attention_d"];
    [self.contentView addSubview:_likeView];
    
    _likeLabel =[[EMLabel alloc] initWithFrame:Rect(PositionX(_likeView) + 2, _hearView.frame.origin.y, lableWidth, 15)];
    _likeLabel.font = lableFont;
    [_likeLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:_likeLabel];
    
}


- (void)setValueWithObj:(BoardcastObj*)obj {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    NSString *gender = @"";
    if (loginStatus.isLogined) {
        gender = user.gender;
    }else {
        gender = loginStatus.gender;
    }
    if ([obj.imageURL isEqualToString:@""]) {
        [_imageView setImage:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:gender]]];
    }else{
        [_imageView yy_setImageWithURL:[NSURL URLWithString:obj.imageURL] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:gender]]];
    }
    _hearLabel.text = obj.seenNum;
    _commentLabel.text = obj.comments;
    _likeLabel.text = obj.likes;

}


- (void)setValueWithDict:(NSDictionary*)dict {
    NSString *urlStr = dict[@"image"];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    NSString *gender = @"";
    if (loginStatus.isLogined) {
        gender = user.gender;
    }else {
        gender = loginStatus.gender;
    }
    [_imageView yy_setImageWithURL:[NSURL URLWithString:urlStr] placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgNameUseSelfGender:gender]]];
    NSString *num = dict[@"seen_num"];
    _hearLabel.text = num;
    NSString *comments = dict[@"comments"];
    _commentLabel.text = comments;
    NSString *like = dict[@"likes"];
    _likeLabel.text = like;
}
@end
