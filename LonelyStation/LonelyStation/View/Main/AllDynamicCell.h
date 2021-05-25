//
//  AllDynamicCell.h
//  LonelyStation
//  全部广播cell
//  Created by 钟铿 on 2018/4/4.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardcastObj.h"
#import "EMTopLabel.h"

@interface AllDynamicCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView *imageView;//头像

@property (nonatomic,strong)UIImageView *picView;//精品view

@property (nonatomic,strong)UIImageView *hearView;//耳机按钮

@property (nonatomic,strong)EMLabel *hearLabel;//多少人听过

@property (nonatomic,strong)UIImageView *commentView;//评论按钮

@property (nonatomic,strong)EMLabel *commentLabel;//多少人评论

@property (nonatomic,strong)UIImageView *likeView;//喜欢按钮

@property (nonatomic,strong)EMLabel *likeLabel;//多少人喜欢

@property (nonatomic,strong)EMTopLabel *titleName;

@property (nonatomic,strong)EMLabel *nickName;

@property (nonatomic,strong)NSString *nickNameStr;


- (void)setValueWithDict:(NSDictionary*)dict;

- (void)setValueWithObj:(BoardcastObj*)obj;

@end
