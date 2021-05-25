//
//  DynamicNomalTitleView.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/3.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "EMView.h"
@class DynamicNomalTitleView;
@protocol DynamicNomarlTitleDelegate <NSObject>

- (void)dynamicNomalDidSelectIndex:(NSInteger)index andDynamicNomalTitleView:(DynamicNomalTitleView*)view;

@end

@interface DynamicNomalTitleView : EMView
@property (nonatomic,weak)id<DynamicNomarlTitleDelegate> delegate;


- (void)setSelectIndex:(int)index;

- (void)setTitleWithArray:(NSArray*)titleArray;

@end
