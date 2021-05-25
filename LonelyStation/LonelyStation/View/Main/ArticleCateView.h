//
//  ArticleCateView.h
//  LonelyStation
//
//  Created by zk on 2016/11/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMView.h"
#import "Categories.h"

@protocol CellBtnClick1Delegate <NSObject>

- (void)didClickCellBtn:(EMButton*)btn andIndex:(NSInteger)index;

@end

@interface ArticleCateView : EMView

@property (nonatomic,strong)Categories *category;

@property (nonatomic,assign)id<CellBtnClick1Delegate> delegate;

@property (nonatomic,assign)NSInteger index;

-(id)initWithFrame:(CGRect)frame;


@end
