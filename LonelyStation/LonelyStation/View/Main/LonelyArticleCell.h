//
//  LonelyArticleCell.h
//  LonelyStation
//
//  Created by zk on 16/10/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Categories.h"

@protocol CellBtnClickDelegate <NSObject>

- (void)didClickCellBtn:(EMButton*)btn andIndex:(NSInteger)index;

@end

@interface LonelyArticleCell : UICollectionViewCell

@property (nonatomic,strong)Categories *category;

@property (nonatomic,assign)id<CellBtnClickDelegate> delegate;

@property (nonatomic,assign)NSInteger index;

-(id)initWithFrame:(CGRect)frame;

@end
