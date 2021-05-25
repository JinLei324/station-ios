//
//  CallImgView.h
//  Test
//
//  Created by zk on 16/9/3.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CallImgView;

@protocol CallImgViewDelegate <NSObject>

- (void)didReachTheMinPoint:(CallImgView*)imgView;

- (void)didStartPan:(CallImgView*)imgView;



@end

@interface CallImgView : UIImageView{
    CGPoint velocity;
    UIPanGestureRecognizer * panGestureRecognizer;
}

@property (nonatomic, assign) BOOL springEnabled;
@property (nonatomic, assign) CGFloat springConstant;
@property (nonatomic, assign) CGFloat dampingCoefficient;
@property (nonatomic, assign) CGPoint restCenter;
@property (nonatomic, assign) CGFloat mass;
@property (nonatomic, assign) UIEdgeInsets panDistanceLimits;
@property (nonatomic, assign) CGFloat panDragCoefficient;
@property (nonatomic, readonly) BOOL panning;
@property (nonatomic, assign) id<CallImgViewDelegate> delegate;

@property (nonatomic, assign) CGFloat minPointY;
@property (nonatomic, assign) BOOL isRight;



- (void)simulateSpringWithDisplayLink:(CADisplayLink *)displayLink;

@end
