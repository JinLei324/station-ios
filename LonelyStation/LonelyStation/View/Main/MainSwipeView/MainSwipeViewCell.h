//
//  MainSwipeViewCell.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/5/1.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainCollectionViewCell.h"


@interface MainSwipeViewCell : UITableViewCell


- (void)setModel:(LonelyStationUser*)lonelyUser andTarget:(id<MainCollectionViewCellDelegate>)target andIndexPath:(NSIndexPath*)indexPath;

@end
