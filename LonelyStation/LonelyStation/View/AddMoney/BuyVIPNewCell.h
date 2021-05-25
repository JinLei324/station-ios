//
//  BuyVIPNewCell.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/6/16.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgramObj.h"



@interface BuyVIPNewCell : UITableViewCell

@property(nonatomic, copy) void (^clickBlock)(void);

- (void)setModel:(ProgramObj*)model;



@end
