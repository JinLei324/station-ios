//
//  NotifyCell.h
//  LonelyStation
//
//  Created by zk on 2016/11/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JPLabel.h"

@interface NotifyCell : UITableViewCell

@property (nonatomic,strong)JPLabel *contentLabel;


@property (nonatomic,strong)UIImageView *goImageView;

@property (nonatomic,assign)CGFloat height;

@end
