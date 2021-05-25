//
//  DynamicAllTitleView.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/2.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "EMView.h"

@protocol DynamicTitleDelegate <NSObject>

- (void)dynamicDidSelectIndex:(NSInteger)index;

@end

@interface DynamicAllTitleView : EMView

@property (nonatomic,weak)id<DynamicTitleDelegate> delegate;

- (void)setTitleWithArray:(NSArray*)titleArray;


@end
