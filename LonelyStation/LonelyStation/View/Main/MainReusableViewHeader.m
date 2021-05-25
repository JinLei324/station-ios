//
//  MainReusableViewHeader.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/1/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainReusableViewHeader.h"

@implementation MainReusableViewHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initViews];
    return self;
}


- (void)initViews{
    _leftLabel = [[EMLabel alloc] initWithFrame:Rect(11, 0, 80, 42)];
    _leftLabel.textColor = RGB(255,255,255);
    _leftLabel.font = ComFont(17);
    [self addSubview:_leftLabel];
    
    _rightLabel =  [[EMLabel alloc] initWithFrame:Rect(kScreenW - 33 - 80, 0, 80, 42)];
    _rightLabel.textColor = RGB(255,255,255);
    _rightLabel.textAlignment = NSTextAlignmentRight;
    _rightLabel.font = ComFont(17);
    [self addSubview:_rightLabel];
    
    _rightImageView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_rightLabel)+5, 13,11*kScale, 16*kScale)];
    _rightImageView.image = [UIImage imageNamed:@"set_go"];
    [self addSubview:_rightImageView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)tapAction:(UITapGestureRecognizer*)tap {
    if (_clickBlock) {
        _clickBlock();
    }
}


@end
