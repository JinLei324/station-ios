//
//  MyGiftsCell.h
//  LonelyStation
//
//  Created by zk on 2017/5/5.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LonelyStationUser.h"

@protocol MyGiftsCellDelegate <NSObject>

- (void)didClickPlayBtn:(UITableViewCell*)cell;

@end

@interface MyGiftsCell : UITableViewCell

@property (nonatomic,strong)LonelyStationUser *lonelyStationUser;

@property (nonatomic,assign)id<MyGiftsCellDelegate> delegate;


- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;

@end
