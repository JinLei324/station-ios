//
//  MainDynamicCell.h
//  LonelyStation
//  情人动态
//  Created by 钟铿 on 2018/1/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardcastObj.h"

@interface MainDynamicCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView *imageView;//头像

@property (nonatomic,strong)UIImageView *hearView;//耳机按钮

@property (nonatomic,strong)EMLabel *hearLabel;//多少人听过

@property (nonatomic,strong)UIImageView *commentView;//评论按钮

@property (nonatomic,strong)EMLabel *commentLabel;//多少人评论

@property (nonatomic,strong)UIImageView *likeView;//喜欢按钮

@property (nonatomic,strong)EMLabel *likeLabel;//多少人喜欢

- (void)setValueWithDict:(NSDictionary*)dict;

- (void)setValueWithObj:(BoardcastObj*)obj;
@end
