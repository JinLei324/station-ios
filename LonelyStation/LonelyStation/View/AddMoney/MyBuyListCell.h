//
//  MyBuyListCell.h
//  LonelyStation
//
//  Created by zk on 2016/10/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyListObj.h"

@interface MyBuyListCell : UITableViewCell

@property (nonatomic,strong)BuyListObj *buyListObj;

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

@end
