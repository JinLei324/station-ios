//
//  UIZKSwipeView.m
//  SwipeView
//
//  Created by zk on 16/5/27.
//
//

#import "UIZKSwipeView.h"

#define ZKRect(x,y,w,h) CGRectMake(x, y, w, h)
#define ZKPoint(x,y) CGPointMake(x, y)
#define ZKSize(x,y) CGSizeMake(x, y)
#define ZKScreenWidth [UIScreen mainScreen].bounds.size.width


@interface UIZKSwipeView ()<UIScrollViewDelegate>{
    UIScrollView *_scrollView;
    UIButton *_currentSelectBtn;
    UIView *_guideView;
    NSArray *_btnArray;
    CGFloat _guideOrginX;
    CGFloat _guideMoveDistance;
}
@end

@implementation UIZKSwipeView

- (void)setupViews:(NSArray*)views andViewHeight:(CGFloat)ViewHight andBtnArray:(NSArray*)btnArray andBtnHeight:(CGFloat)btnHight andGuideView:(UIView*)guideView andBtnViewDistance:(CGFloat)distance andSperateColor:(UIColor*)color andBtnSperateSize:(CGSize)spSize andSperateColor:(UIColor*)spColor {
    //不处理单个view和btn的
    if (!views || !btnArray || views.count <= 1 || btnArray.count <= 1 || views.count != btnArray.count) {
        return;
    }
    _btnArray = btnArray;
    //摆好btn
    CGSize size = self.frame.size;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat sperateWidth = spSize.width;
    CGFloat btnWidth = (size.width - sperateWidth*(btnArray.count-1))/btnArray.count;
    if (!_scrollView) {
        CGFloat scrollY = btnHight + distance;
        _scrollView = [[UIScrollView alloc] initWithFrame:ZKRect(0, scrollY, ZKScreenWidth, ViewHight)];
        _scrollView.delegate = self;
        _scrollView.contentSize = ZKSize(ZKScreenWidth*views.count, 0);
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        //间隔的View
        UIView *distanceView = [[UIView alloc] initWithFrame:ZKRect(0, scrollY-distance, ZKScreenWidth, distance)];
        distanceView.backgroundColor = color;
        UIView *line1 = [[UIView alloc] initWithFrame:ZKRect(0, 0, self.frame.size.width, 1)];
        line1.backgroundColor = [UIColor colorWithRed:236.0f/255.0f green:236.0f/255.0f blue:236.0f/255.0f alpha:1.0f];
        UIView *line2 = [[UIView alloc] initWithFrame:ZKRect(0, distanceView.frame.size.height-1, self.frame.size.width, 1)];
        line2.backgroundColor = line1.backgroundColor;
        [distanceView addSubview:line1];
        [distanceView addSubview:line2];
        [self addSubview:distanceView];
    }
   
    
    for (int i = 0; i < btnArray.count; i++) {
        UIButton *btn = [btnArray objectAtIndex:i];
        btn.frame = ZKRect(x + (sperateWidth + btnWidth)*i, y, btnWidth, btnHight);
        btn.tag = 100 + i;
        [self addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            _currentSelectBtn = btn;
            guideView.frame = ZKRect(0, btnHight-guideView.frame.size.height, guideView.frame.size.width, guideView.frame.size.height);
            guideView.center = ZKPoint(btn.center.x, guideView.center.y);
            _guideView = guideView;
            _guideOrginX = _guideView.frame.origin.x;
            _guideMoveDistance = sperateWidth + btnWidth;
            [self addSubview:_guideView];
        }
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        if (i!= btnArray.count - 1) {
            UIView *sperateView = [[UIView alloc] init];
            sperateView.backgroundColor = spColor;
            sperateView.frame = ZKRect(btn.frame.origin.x + btn.frame.size.width, 0, spSize.width, spSize.height);
            sperateView.center = ZKPoint(sperateView.center.x, btn.center.y);
            [self addSubview:sperateView];
        }
        [self bringSubviewToFront:_guideView];
         //放好底下的View；
        UIView *bottomView = [views objectAtIndex:i];
        bottomView.frame = ZKRect(0+ZKScreenWidth*i, 0, ZKScreenWidth, ViewHight);
        [_scrollView addSubview:bottomView];
    }
    
   
}

- (void)btnAction:(UIButton*)btn{
    if (_currentSelectBtn != btn) {
        if (!_currentSelectBtn) {
            _currentSelectBtn = btn;
        }else{
            _currentSelectBtn.selected = NO;
        }
        btn.selected = !btn.selected;
        _currentSelectBtn = btn;
        NSInteger index = btn.tag - 100;
        _currentSelectIndex = index;
        CGFloat x = index * ZKScreenWidth;
        [UIView animateWithDuration:0.3 animations:^{
            _guideView.center = ZKPoint(btn.center.x, _guideView.center.y);
            [_scrollView setContentOffset:ZKPoint(x, 0) animated: NO];
        }];
    }
}

#pragma scrollViewDelegate

-(void) modifyTopScrollViewPositiong: (UIScrollView *) scrollView{
    int x = scrollView.contentOffset.x/ZKScreenWidth;
    for (UIButton *btn in _btnArray) {
        if(btn.tag - 100 == x){
            btn.selected = YES;
            _currentSelectBtn = btn;
            NSInteger index = btn.tag - 100;
            _currentSelectIndex = index;
        }else{
            btn.selected = NO;
        }
    }
}

///拖拽后调用的方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self modifyTopScrollViewPositiong:scrollView];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self modifyTopScrollViewPositiong:scrollView];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([_scrollView isEqual:scrollView]) {
        CGRect frame = _guideView.frame;
        frame.origin.x = _guideOrginX + (scrollView.contentOffset.x/ZKScreenWidth)*_guideMoveDistance;
        _guideView.frame = frame;
    }
    
}

@end
