//
//  ArticleCateCell.h
//  LonelyStation
//
//  Created by zk on 16/10/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleObj.h"

@interface ArticleCateCell : UITableViewCell

@property (nonatomic,strong)ArticleObj *articleObj;

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

@end
