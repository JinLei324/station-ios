//
//  EMScrollView.m
//  LonelyStation
//
//  Created by zk on 16/6/7.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMScrollView.h"

@implementation EMScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _scrollDirection = 0;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.scrollDirection == 0){//we need to determine direction
        //use the difference between positions to determine the direction.
        if (ABS(self.scrollViewStartPosPoint.x-scrollView.contentOffset.x)<
            ABS(self.scrollViewStartPosPoint.y-scrollView.contentOffset.y)){
            //Vertical Scrolling
            self.scrollDirection = 1;
        } else {
            //Horitonzal Scrolling
            self.scrollDirection = 2;
        }
    }
    //Update scroll position of the scrollview according to detected direction.
    if (self.scrollDirection == 1) {
        scrollView.contentOffset = CGPointMake(self.scrollViewStartPosPoint.x,scrollView.contentOffset.y);
    } else if (self.scrollDirection == 2){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,self.scrollViewStartPosPoint.y);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollViewStartPosPoint = scrollView.contentOffset;
    self.scrollDirection = 0;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        self.scrollDirection =0;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.scrollDirection =0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event]; // always forward
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}


@end
