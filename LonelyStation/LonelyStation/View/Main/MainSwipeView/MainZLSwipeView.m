//
//  MySwipeView.m
//  ZLSwipeableViewDemo
//
//  Created by Louis on 2018/5/10.
//  Copyright © 2018年 Zhixuan Lai. All rights reserved.
//

#import "MainZLSwipeView.h"
#import "MainZLSwipeChildView.h"
#import "Masonry.h"
#import "EMView.h"

@interface MainZLSwipeView()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic) NSUInteger colorIndex;
@property (nonatomic,strong)EMView *maskView;


@end

@implementation MainZLSwipeView

- (instancetype)initWithFrame:(CGRect)frame andDataArray:(NSArray*)array andDelegate:(id<MainCollectionViewCellDelegate>) delegate{
    self = [super initWithFrame:frame];
    _dataArray = array;
    _mainDelegate = delegate;
    [self initViews];
    return self;
}

- (void)initViews {
    ZLSwipeableView *swipeableView = [[ZLSwipeableView alloc] initWithFrame:CGRectZero];
    self.swipeableView = swipeableView;
    [self addSubview:self.swipeableView];
    self.swipeableView.frame = self.bounds;
    // Required Data Source
    self.swipeableView.dataSource = self;
    
    // Optional Delegate
    self.swipeableView.delegate = self;
    
    self.swipeableView.translatesAutoresizingMaskIntoConstraints = NO;
    _colorIndex = 0;
    [swipeableView loadViewsIfNeeded];
    
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    BOOL isThisAccountFirstComing = (BOOL)[defaluts objectForKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
    if (!isThisAccountFirstComing) {
        //再加一个maskView
        _maskView = [EMView new];
        [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.and.bottom.mas_equalTo(0);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_maskView addGestureRecognizer:tap];
        
        _maskView.backgroundColor = RGBA(0, 0, 0, 0.6);
        UIImageView *leftView = [UIImageView new];
        [_maskView addSubview:leftView];
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(280*kScale);
            make.left.mas_equalTo(71*kScale);
            make.size.mas_equalTo(Size(46*kScale, 46*kScale));
        }];
        leftView.image = [UIImage imageNamed:@"turn_left"];
        EMLabel * leftLabel = [EMLabel new];
        [_maskView addSubview:leftLabel];
        leftLabel.font = ComFont(15*kScale);
        leftLabel.textColor = RGB(0,255,255);
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftView.mas_bottom).offset(15*kScale);
            make.left.mas_equalTo(41*kScale);
            make.size.mas_equalTo(Size(100*kScale, 15*kScale));
        }];
        leftLabel.text = Local(@"LeftDesp");
        leftLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *rightView = [UIImageView new];
        [_maskView addSubview:rightView];
        [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(280*kScale);
            make.right.mas_equalTo(-71*kScale);
            make.size.mas_equalTo(Size(46*kScale, 46*kScale));
        }];
        rightView.image = [UIImage imageNamed:@"turn_right"];
        
        EMLabel * rightLabel = [EMLabel new];
        [_maskView addSubview:rightLabel];
        rightLabel.font = ComFont(15*kScale);
        rightLabel.textColor = RGB(0,255,255);
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rightView.mas_bottom).offset(15*kScale);
            make.right.mas_equalTo(-41*kScale);
            make.size.mas_equalTo(Size(100*kScale, 15*kScale));
        }];
        rightLabel.text = Local(@"RightDesp");
        rightLabel.textAlignment = NSTextAlignmentCenter;
        [defaluts setBool:YES forKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
    }
    
}

- (void)tapAction {
    [_maskView removeFromSuperview];
    _maskView = nil;
}


- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction {
    NSLog(@"did swipe in direction: %zd", direction);
    if (direction == ZLSwipeableViewDirectionRight) {
        [self.superview removeFromSuperview];
    }else if(direction == ZLSwipeableViewDirectionLeft){
       UIView *view =  swipeableView.topView;
        if (view == nil) {
            [self.superview removeFromSuperview];
        }
    }
}


- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView {
    if (self.colorIndex >= self.dataArray.count) {
        return nil;
    }
    
    MainZLSwipeChildView *view = [[MainZLSwipeChildView alloc] initWithFrame:swipeableView.bounds];
    view.backgroundColor = [UIColor whiteColor];
    LonelyStationUser *user = _dataArray[self.colorIndex];
    [view setModel:user andTarget:_mainDelegate andIndexPath:[NSIndexPath indexPathForRow:_colorIndex inSection:0]];
    self.colorIndex++;
    return view;
}

@end

