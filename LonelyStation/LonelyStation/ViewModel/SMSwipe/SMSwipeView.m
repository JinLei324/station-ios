//
//  SMSwipeView.m
//  赵龙
#import "SMSwipeView.h"

#define degreeTOradians(x) (M_PI * (x)/180)
//childView距离父View左右的距离
const int LEFT_RIGHT_MARGIN=10;
//当前view距离父view的顶部的值
const int TOP_MARGTIN=16;

@interface SMSwipeView()
//已经划动到边界外的一个view
@property(nonatomic,weak)UITableViewCell * viewRemove;
//放当前显示的子View的数组
@property(nonatomic,strong)NSMutableArray * cacheViews;
//view总共的数量
@property(nonatomic,assign)int totalNum;
//当前的下标
@property(nonatomic,assign)int nowIndex;
//触摸开始的坐标
@property(nonatomic,assign)CGPoint pointStart;
//上一次触摸的坐标
@property(nonatomic,assign)CGPoint pointLast;
//最后一次触摸的坐标
@property(nonatomic,assign)CGPoint pointEnd;
//正在显示的cell
@property(nonatomic,weak)UITableViewCell * nowCell;
//下一个cell
@property(nonatomic,weak)UITableViewCell * nextCell;
//第三个cell
@property(nonatomic,weak)UITableViewCell * thirdCell;

//是否是第一次执行
@property(nonatomic,assign)BOOL isFirstLayoutSub;

@end

@implementation SMSwipeView

//从xib中加载该类
-(void)awakeFromNib{
    [super awakeFromNib];
    [self initSelf];
}
//直接用方法初始化
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    [self initSelf];
    return self;
}

//进行一些自身的初始化和设置
-(void)initSelf{
    self.clipsToBounds=YES;
    self.cacheViews=[[NSMutableArray alloc]init];
    //手势识别
    UIPanGestureRecognizer * pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

//布局subview的方法
-(void)layoutSubviews{
    if(!self.isFirstLayoutSub){
        self.isFirstLayoutSub=YES;
        self.w=self.bounds.size.width;
        self.h=self.bounds.size.height;
//        [self reloadData];
    }
}

//重新加载数据方法，会再首次执行layoutSubviews的时候调用
-(void)reloadData{
    if (!self.delegate||![self.delegate respondsToSelector:@selector(SMSwipeGetView:withIndex:)]||![self.delegate respondsToSelector:@selector(SMSwipeGetTotaleNum:)]) {
        return;
    }
    self.totalNum=(int)[self.delegate SMSwipeGetTotaleNum:self];
    self.viewRemove=nil;
    UITableViewCell * nowCell=[self.delegate SMSwipeGetView:self withIndex:self.nowIndex];
    
    UITableViewCell * nextCell=[self.delegate SMSwipeGetView:self withIndex:self.nowIndex+1<self.totalNum?self.nowIndex+1:0];
    
    UITableViewCell * thirdCell=[self.delegate SMSwipeGetView:self withIndex:self.nowIndex+2<self.totalNum?self.nowIndex+2:self.nowIndex+2-self.totalNum];
    
    
    if (self.isStackCard) {
        [thirdCell setAlpha:0.3f];
        [nextCell setAlpha:0.5f];
        [nowCell setAlpha:1];
    }
    
    [thirdCell removeFromSuperview];
    thirdCell.layer.anchorPoint=CGPointMake(1, 1);
//    thirdCell.frame=CGRectMake(LEFT_RIGHT_MARGIN*2, 0, self.w-2*2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
    thirdCell.frame=CGRectMake(LEFT_RIGHT_MARGIN*2, TOP_MARGTIN, self.w-2*2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);

    [self addSubview:thirdCell];
    self.thirdCell=thirdCell;
    
    [nextCell removeFromSuperview];
    nextCell.layer.anchorPoint=CGPointMake(1, 1);
    nextCell.frame=CGRectMake(LEFT_RIGHT_MARGIN, TOP_MARGTIN/2*1, self.w-2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
    
    [self addSubview:nextCell];
    self.nextCell=nextCell;
    
    [nowCell removeFromSuperview];
    nowCell.layer.anchorPoint=CGPointMake(1, 1);
//    nowCell.frame=CGRectMake(0, TOP_MARGTIN, self.w, self.h-TOP_MARGTIN);
    nowCell.frame= CGRectMake(0, 0, self.w, self.h-TOP_MARGTIN);
    [self addSubview:nowCell];
    self.nowCell=nowCell;
    [self hideOtherCell];
    
}


- (void)hideOtherCell{
    for (int i = 0; i < self.totalNum; i++) {
        UITableViewCell *cell = [self.delegate SMSwipeGetView:self withIndex:i];
        if (cell == _nowCell || cell == _nextCell || cell == _thirdCell) {
            cell.hidden = NO;
        }else {
            cell.hidden = YES;
        }
    }
    
    for (int i = 0; i < self.cacheViews.count; i++) {
        UITableViewCell *cell = self.cacheViews[i];
        if (cell == _nowCell || cell == _nextCell || cell == _thirdCell) {
            cell.hidden = NO;
        }else {
            cell.hidden = YES;
        }
    }
    
}




#pragma mark swipe触摸的相关手势处理
-(void)swipe:(UISwipeGestureRecognizer*)sender{
    NSLog(@"swipe");
}

-(void)pan:(UIPanGestureRecognizer*)sender{
    CGPoint translation = [sender translationInView: self];
    //CGPoint speed=[sender velocityInView:self];//获取速度
    if (sender.state==UIGestureRecognizerStateBegan) {
        //NSLog(@"begin");
        self.pointStart=translation;
        self.pointLast=translation;
    }
    
    if (sender.state==UIGestureRecognizerStateEnded) {
        //NSLog(@"end");
        CGFloat xTotalMove=translation.x-self.pointStart.x;
        if (xTotalMove<0) {
            [self swipeEnd];
        }else{
            [self swipeGoBack];
        }
        
    }
    //    NSLog(@"%@%f%@%f",@"x:",speed.x,@"y:",speed.y);
    //NSLog(@"%@%f%@%f",@"x:",translation.x,@"y:",translation.y);
}

/**
 *  @author StoneMover, 16-12-29 14:12:33
 *
 *  @brief 获取为显示的cell,复用机制
 *
 *  @param identifier id标志
 *
 *  @return 返回的cell,如果缓存中没有则返回空
 */
-(UITableViewCell*)dequeueReusableUIViewWithIdentifier:(NSString *)identifier{
    
    for (UITableViewCell * cell in self.cacheViews) {
        if ([identifier isEqualToString:cell.reuseIdentifier]) {
            [self.cacheViews removeObject:cell];
            return cell;
        }
    }
    
    return nil;
}

//滑动到下一个界面
-(void)swipeEnd{
    [UIView animateWithDuration:0.3 animations:^{
        self.nextCell.transform= CGAffineTransformMakeRotation(degreeTOradians(0));
    }];
    
    //self.nowCell.transform= CGAffineTransformMakeRotation(degreeTOradians(0));
    CGPoint center=self.nowCell.center;
    [UIView animateWithDuration:0.3 animations:^{
        self.nowCell.center=CGPointMake(center.x-self.w, center.y);
        self.nowCell.transform= CGAffineTransformMakeRotation(degreeTOradians(0));
        //        [self.nowCell setAlpha:0.0];
    } completion:^(BOOL finished) {
        self.nowIndex++;
        if (self.nowIndex >= self.totalNum) {
            if (_delegate && [_delegate respondsToSelector:@selector(SMSwipeisLast)]) {
                [_delegate SMSwipeisLast];
            }
            return;
        }
        
        
        self.nowIndex=self.nowIndex<self.totalNum?self.nowIndex:0;
        if (self.viewRemove&&[self isNeedAddToCache:self.viewRemove]) {
            [self.cacheViews addObject:self.viewRemove];
            [self.viewRemove removeFromSuperview];
        }
        self.viewRemove=self.nowCell;
        //self.viewRemove.layer.anchorPoint=CGPointMake(0, 0);
        //self.viewRemove.transform=CGAffineTransformMakeRotation(degreeTOradians(-35));
        
        
        self.nowCell=self.nextCell;
        self.nextCell=self.thirdCell;
        
        
        
        UITableViewCell * thirdCell=[self.delegate SMSwipeGetView:self withIndex:self.nowIndex+2<self.totalNum?(int)self.nowIndex+2:(int)self.nowIndex+2-(int)self.totalNum];
        
        [thirdCell removeFromSuperview];
        
        thirdCell.layer.anchorPoint=CGPointMake(1, 1);
        thirdCell.frame=CGRectMake(LEFT_RIGHT_MARGIN*2, TOP_MARGTIN, self.w-2*2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
//        thirdCell.frame=CGRectMake(LEFT_RIGHT_MARGIN*2, 0, self.w-2*2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
        self.thirdCell=thirdCell;
        
        
        
        if (self.isStackCard) {
            [self.thirdCell setAlpha:0.3f];
            [self.nextCell setAlpha:0.5f];
            [self.nowCell setAlpha:1];
        }
        
        [self insertSubview:thirdCell belowSubview:self.nextCell];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.nowCell.frame = CGRectMake(0, 0, self.w, self.h-TOP_MARGTIN);
//            self.nowCell.frame=CGRectMake(0, TOP_MARGTIN, self.w, self.h-TOP_MARGTIN);
            self.nextCell.frame=CGRectMake(LEFT_RIGHT_MARGIN, TOP_MARGTIN/2*1, self.w-2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
        }];
    }];
    [self hideOtherCell];
}

//滑动到上一个界面
-(void)swipeGoBack{
    
    if (!self.viewRemove) {
        NSLog(@"!viewRemove");
        return;
    }
    
    if (self.nowIndex==0) {
        NSLog(@"!viewRemove+index");
        return;
    }
    
//    CGPoint center=self.viewRemove.center;
    
    self.nowIndex--;
    
    //    if ([self isNeedAddToCache:self.thirdCell]) {
    //        [self.cacheViews addObject:self.thirdCell];
    //    }
    [self.thirdCell removeFromSuperview];
    
    
    self.thirdCell=self.nextCell;
    self.nextCell=self.nowCell;
    self.nowCell=self.viewRemove;
    
    if (self.nowIndex==0) {
        self.viewRemove=nil;
        
    }else{
        UITableViewCell * cell=[self.delegate SMSwipeGetView:self withIndex:(int)self.nowIndex-1];
        [cell removeFromSuperview];
        [self insertSubview:cell aboveSubview:self.nowCell];
        cell.layer.anchorPoint=CGPointMake(1, 1);
        cell.frame=self.viewRemove.frame;
        self.viewRemove=cell;
    }
    
   
    
    [UIView animateWithDuration:.5 animations:^{
//        self.nowCell.center=CGPointMake(center.x+self.w, center.y);
        self.nowCell.frame = CGRectMake(0, 0, self.w, self.h-TOP_MARGTIN);
        
        self.nowCell.transform= CGAffineTransformMakeRotation(degreeTOradians(0));
        self.nextCell.frame=CGRectMake(LEFT_RIGHT_MARGIN, TOP_MARGTIN/2*1, self.w-2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
        self.thirdCell.frame=CGRectMake(LEFT_RIGHT_MARGIN*2, TOP_MARGTIN, self.w-2*2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
        if (self.isStackCard) {
            [self.thirdCell setAlpha:0.3f];
            [self.nextCell setAlpha:0.5f];
            [self.nowCell setAlpha:1];
        }
//        self.thirdCell.frame=CGRectMake(LEFT_RIGHT_MARGIN*2, 0, self.w-2*2*LEFT_RIGHT_MARGIN, self.h-TOP_MARGTIN);
    }];
    [self hideOtherCell];

}

//是否需要加入到缓存中去
-(BOOL)isNeedAddToCache:(UITableViewCell*)cell{
    for (UITableViewCell * cellIn in self.cacheViews) {
        if ([cellIn.reuseIdentifier isEqualToString:cell.reuseIdentifier]) {
            
            return NO;
        }
    }
    return YES;
}

@end
