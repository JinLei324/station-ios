//
//  ArticleObj.h
//  LonelyStation
//
//  Created by zk on 16/10/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface ArticleObj : EMObject

@property (nonatomic,copy)NSString *productId;//文章Id
@property (nonatomic,copy)NSString *productName;//文章标题
@property (nonatomic,copy)NSString *productNo;//文章来源缩写
@property (nonatomic,copy)NSString *productMsg;//文章来源网址
@property (nonatomic,copy)NSString *productImgName;//封面照
@property (nonatomic,copy)NSString *productImgName0;//封面照1
@property (nonatomic,copy)NSString *productImgName2;//自己上传的视频网址
@property (nonatomic,copy)NSString *productImgName3;//网络抓的视频网址
@property (nonatomic,copy)NSString *productDateAdd;//文章日期
@property (nonatomic,copy)NSString *product18Ban;//是否18禁
@property (nonatomic,copy)NSString *isFavorite;//是否已经加入收藏
@property (nonatomic,copy)NSString *productClick;//文章点击次数
@property (nonatomic,copy)NSString *productContent;

- (instancetype)initWithDict:(NSDictionary*)dict;

@end
