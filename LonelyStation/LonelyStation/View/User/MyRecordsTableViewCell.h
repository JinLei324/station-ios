//
//  MyRecordsTableViewCell.h
//  LonelyStation
//
//  Created by zk on 16/8/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardcastObj.h"
#import "LonelyUser.h"

@interface MyRecordsTableViewCell : UITableViewCell

@property(nonatomic,strong)LonelyUser *user;

@property(nonatomic,strong)BoardcastObj *boardcastObj;

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier;



@end
