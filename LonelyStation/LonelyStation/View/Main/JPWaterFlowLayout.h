//
//  JPWaterFlowLayout.h
//  瀑布流
//
//  Created by ios app on 16/2/21.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JPWaterFlowLayout;

@protocol JPWaterFlowLayoutDelegate <NSObject>

//必须实现
@required
/**
 * 让代理根据给出的宽度计算出item高度
 */
-(CGFloat)waterFlowLayout:(JPWaterFlowLayout *)waterFlowLayout heightForItemAtIndex:(NSUInteger)index itemWidth:(CGFloat)itemWidth;

@optional
-(NSInteger)colCountInWaterFlowLayout:(JPWaterFlowLayout *)waterFlowLayout;         //cell的总列数
-(CGFloat)colMarginInWaterFlowLayout:(JPWaterFlowLayout *)waterFlowLayout;          //cell的列间距
-(CGFloat)rowMarginInWaterFlowLayout:(JPWaterFlowLayout *)waterFlowLayout;          //cell的行间距
-(UIEdgeInsets)edgeInsetsInWaterFlowLayout:(JPWaterFlowLayout *)waterFlowLayout;    //collectionView的内容间距

@end

@interface JPWaterFlowLayout : UICollectionViewLayout
@property(nonatomic,weak)id<JPWaterFlowLayoutDelegate>delegate;
@end
