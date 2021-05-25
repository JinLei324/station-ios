//
//  BuyVIPCell.h
//  LonelyStation
//
//  Created by zk on 2016/10/16.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyVIPCell : UITableViewCell

@property (nonatomic,copy)NSString *likeCard;
@property (nonatomic,copy)NSString *cardDesp;
@property (nonatomic,strong)EMButton *radioBtn;


- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

@end
