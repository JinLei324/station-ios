//
//  UIZKSwipeView.h
//  SwipeView
//
//  Created by zk on 16/5/27.
//  这个是要把左右滑动的swipeView抽离出来，上面固定几个按钮，下面几个tableView，可左右滑动切换，做到轻量级，易用
//

#import <UIKit/UIKit.h>

@interface UIZKSwipeView : UIView


@property(nonatomic,assign)NSInteger currentSelectIndex;

- (void)setupViews:(NSArray*)views andViewHeight:(CGFloat)ViewHight andBtnArray:(NSArray*)btnArray andBtnHeight:(CGFloat)btnHight andGuideView:(UIView*)guideView andBtnViewDistance:(CGFloat)distance andSperateColor:(UIColor*)color andBtnSperateSize:(CGSize)spSize andSperateColor:(UIColor*)spColor;


@end
