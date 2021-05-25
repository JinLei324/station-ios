//
//  JPWaterFlowLayout.m
//  瀑布流
//
//  Created by ios app on 16/2/21.
//  Copyright © 2016年 cb2015. All rights reserved.
//

#import "JPWaterFlowLayout.h"

//默认列数
static const NSInteger JPDefaultColCount=3;

//默认cell列间距
static const CGFloat JPDefaultColMargin=10;

//默认cell行间距
static const CGFloat JPDefaultRowMargin=10;

//collectionView的内容间距
static const UIEdgeInsets JPDefaultEdgeInsets={10,10,10,10};//定义静态的结构体就使用{}括住相应结构体的参数



@interface JPWaterFlowLayout ()
@property(nonatomic,strong)NSMutableArray *attrsArray;  //所有cell的布局属性
@property(nonatomic,strong)NSMutableArray *colHeights;  //所有列的高度

@property(nonatomic,assign)CGFloat contentHeight;

-(NSInteger)colCount;
-(CGFloat)colMargin;
-(CGFloat)rowMargin;
-(UIEdgeInsets)edgeInsets;
@end

@implementation JPWaterFlowLayout

//*****  协议数据处理

-(NSInteger)colCount{
    if ([self.delegate respondsToSelector:@selector(colCountInWaterFlowLayout:)]) {
        return [self.delegate colCountInWaterFlowLayout:self];
    }else{
        return JPDefaultColCount;
    }
}

-(CGFloat)colMargin{
    if ([self.delegate respondsToSelector:@selector(colMarginInWaterFlowLayout:)]) {
        return [self.delegate colMarginInWaterFlowLayout:self];
    }else{
        return JPDefaultColMargin;
    }
}

-(CGFloat)rowMargin{
    if ([self.delegate respondsToSelector:@selector(rowMarginInWaterFlowLayout:)]) {
        return [self.delegate rowMarginInWaterFlowLayout:self];
    }else{
        return JPDefaultRowMargin;
    }
}

-(UIEdgeInsets)edgeInsets{
    if ([self.delegate respondsToSelector:@selector(edgeInsetsInWaterFlowLayout:)]) {
        return [self.delegate edgeInsetsInWaterFlowLayout:self];
    }else{
        return JPDefaultEdgeInsets;
    }
}

//*****

-(NSMutableArray *)attrsArray{
    if (!_attrsArray) {
        _attrsArray=[NSMutableArray array];
    }
    return _attrsArray;
}

-(NSMutableArray *)colHeights{
    if (!_colHeights) {
        _colHeights=[NSMutableArray array];
    }
    return _colHeights;
}

/**
 * 初始化
 */
-(void)prepareLayout{
    [super prepareLayout];
    
    self.contentHeight=0;
    
    //清除之前所有的布局属性（每次collectionView刷新一遍都会重新调用一次prepareLayout，例如上下拉刷新）
    [self.attrsArray removeAllObjects];
    
    //先清除之前计算的所有高度
    [self.colHeights removeAllObjects];
    //再初始化
    for (NSInteger i=0; i<self.colCount; i++) {
        [self.colHeights addObject:@(self.edgeInsets.top)];
    }
    
    //获取cell的总数
    NSInteger count=[self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i=0; i<count; i++) {
        //创建位置
        NSIndexPath *indexPath=[NSIndexPath indexPathForItem:i inSection:0];
        //获取indexPath位置cell对应的布局属性（不能用super调用，因为super调用是个空方法，要用self调用自定义的方法）
        UICollectionViewLayoutAttributes *attrs=[self layoutAttributesForItemAtIndexPath:indexPath];
        
        [self.attrsArray addObject:attrs];
    }
}


/**
 * 决定cell的排布（在继承UICollectionViewLayout会多次调用此方法，将计算过程放到prepareLayout确保计算过程只执行一次，除非刷新collectionView）
 */
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{

    return self.attrsArray;
    
}

/**
 * 返回indexPath位置cell对应的布局属性
 */
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{

    //创建布局属性
    UICollectionViewLayoutAttributes *attrs=[UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    //collectionView宽度
    CGFloat collectionViewW=self.collectionView.frame.size.width;
    
    //设置布局属性的frame
    
    
    CGFloat width=(collectionViewW-self.edgeInsets.left-self.edgeInsets.right-(self.colCount-1)*self.colCount)/self.colCount;  //(总宽度-边缘间距-列间距)/总列数
    
    CGFloat height=[self.delegate waterFlowLayout:self heightForItemAtIndex:indexPath.item itemWidth:width];
    
//    //找出高度最小的那一列
//    __block NSInteger destCol=0;
//    
//    //最小高度（要在block中修改外部变量，要声明为__block）
//    __block CGFloat minColHeight=MAXFLOAT;
//    
//    //遍历所有列高度数组
//    [self.colHeights enumerateObjectsUsingBlock:^(NSNumber *colHeightNum, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat colHeight=colHeightNum.doubleValue;
//        if (minColHeight>colHeight) {
//            minColHeight=colHeight;
//            destCol=idx;
//        }
//    }];
    
    //使用for循环进行遍历（先获取第一个变量，那每一次遍历就可以减少一次比较，对于这种多次调用的方法能减少比较过程就减少）
    
    //找出高度最小的那一列
    NSInteger destCol=0;
    
    //最小高度
    CGFloat minColHeight=[self.colHeights[0] doubleValue];
    
    //遍历所有列高度数组
    for (NSInteger i=1; i<self.colCount; i++) {
        
        CGFloat colHeight=[self.colHeights[i] doubleValue];
        
        if (minColHeight>colHeight) {
            minColHeight=colHeight;
            destCol=i;
        }
        
    }
    
    CGFloat x=self.edgeInsets.left+destCol*(width+self.colMargin);
    CGFloat y=minColHeight;
    if (y!=self.edgeInsets.top) {
        y+=self.rowMargin;
    }
    
    attrs.frame=CGRectMake(x, y, width, height);
    
    //刷新最短那列的高度
    self.colHeights[destCol]=@(CGRectGetMaxY(attrs.frame));
    
    CGFloat contentHeight=[self.colHeights[destCol] doubleValue];
    
    if (self.contentHeight<contentHeight) {
        self.contentHeight=contentHeight;
    }
    
//    NSLog(@"%ld,%ld,%.2lf",indexPath.item,destCol,self.contentHeight);
    return attrs;
}

-(CGSize)collectionViewContentSize{
   
//    CGFloat maxColHeight=[self.colHeights[0] doubleValue];
//    
//    //遍历所有列高度数组
//    for (NSInteger i=1; i<self.colCount; i++) {
//        CGFloat colHeight=[self.colHeights[i] doubleValue];
//        if (maxColHeight<colHeight) {
//            maxColHeight=colHeight;
//        }
//    }
//    
//    return CGSizeMake(0, maxColHeight+self.edgeInsets.bottom);
    
    return CGSizeMake(0, self.contentHeight+self.edgeInsets.bottom);
}

@end
