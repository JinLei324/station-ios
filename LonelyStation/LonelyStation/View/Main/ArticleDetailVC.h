//
//  ArticleDetailVC.h
//  LonelyStation
//
//  Created by zk on 16/10/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "ArticleObj.h"
#import "Categories.h"
@import GoogleMobileAds;


@interface ArticleDetailVC : EMViewController
@property (nonatomic,strong)ArticleObj *article;
@property (nonatomic,copy)NSString *articleID;

@property (nonatomic,strong)Categories *category;


@end
