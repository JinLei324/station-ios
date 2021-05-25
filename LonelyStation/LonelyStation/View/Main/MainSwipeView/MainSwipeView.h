//
//  MainSwipeView.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/5/1.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "EMView.h"
#import "MainSwipeViewCell.h"


@interface MainSwipeView : EMView

@property (nonatomic,strong)NSArray *dataArray;

@property (nonatomic,weak)id<MainCollectionViewCellDelegate> mainDelegate;

@end
