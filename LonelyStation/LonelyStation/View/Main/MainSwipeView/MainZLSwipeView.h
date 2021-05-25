//
//  MySwipeView.h
//  ZLSwipeableViewDemo
//
//  Created by Louis on 2018/5/10.
//  Copyright © 2018年 Zhixuan Lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLSwipeableView.h"
#import "MainCollectionViewCell.h"

@interface MainZLSwipeView : UIView<ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (nonatomic, strong) ZLSwipeableView *swipeableView;

@property (nonatomic,weak)id<MainCollectionViewCellDelegate> mainDelegate;


- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView;

- (instancetype)initWithFrame:(CGRect)frame andDataArray:(NSArray*)array andDelegate:(id<MainCollectionViewCellDelegate>) delegate;

@end

