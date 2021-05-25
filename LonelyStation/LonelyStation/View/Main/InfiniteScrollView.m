//
//  InfiniteScrollView.m
//  InfiniteScrollViewDemo
//
//  Created by Snow on 5/1/13.
//  Copyright (c) 2013 Snow. All rights reserved.
//

#import "InfiniteScrollView.h"

@implementation InfiniteScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect bounds = [[UIScreen mainScreen] bounds];

        self.contentSize = CGSizeMake(0, bounds.size.height*10);

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        CGRect bounds = [[UIScreen mainScreen] bounds];
        
        self.contentSize = CGSizeMake(0, bounds.size.height*4);
        
        [self setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)recenterIfNecessary{
    CGPoint currentOffset = [self contentOffset];
    CGFloat contentHeight = [self contentSize].height;
    
    CGFloat centerOffsetY = (contentHeight - [self bounds].size.height) / 2.0;
    CGFloat distanceFromCenter = (CGFloat)fabs(currentOffset.y - centerOffsetY);
    if (distanceFromCenter > (contentHeight / 3.0)) {
        self.contentOffset = CGPointMake(self.contentOffset.x, centerOffsetY);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self recenterIfNecessary];
}

@end
