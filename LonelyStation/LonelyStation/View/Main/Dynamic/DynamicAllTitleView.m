//
//  DynamicAllTitleView.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/2.
//  Copyright © 2018年 zk. All rights reserved.
//  分类title
//

#import "DynamicAllTitleView.h"
#import "UIUtil.h"

@interface DynamicAllTitleView()

@property (nonatomic,strong)UIScrollView *titleScrollView;
@property (nonatomic,strong)EMButton *selectedBtn;


@end

@implementation DynamicAllTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initViews];
    return self;
}


- (void)initViews {
    _titleScrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_titleScrollView];
    _titleScrollView.showsHorizontalScrollIndicator = NO;
}

- (void)setTitleWithArray:(NSArray*)titleArray {
    CGFloat x = 0;
    for (int i = 0; i < titleArray.count; i++) {
        EMButton *button = [[EMButton alloc] initWithFrame:Rect(10*kScale+x, 5, 73*kScale, 33*kScale) andConners:3*kScale];
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 5;
        button.layer.borderColor = RGB(145,90,173).CGColor;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = ComFont(15*kScale);
        button.backgroundColor =RGB(255, 255, 255);
        [button setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.titStr = [NSString stringWithFormat:@"%d",i];
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [_titleScrollView addSubview:button];
        x += 73*kScale + 10*kScale;
        if (i == 1) {
            [self action:button];
        }else {
            button.backgroundColor = [UIColor whiteColor];
        }
    }
    _titleScrollView.contentSize = Size(x, 0);
}

- (void)action:(EMButton*)btn {
    if (_selectedBtn != btn) {
        if([@"0" isEqualToString:btn.titStr]){
            if (_delegate && [_delegate respondsToSelector:@selector(dynamicDidSelectIndex:)]) {
                [_delegate dynamicDidSelectIndex:[btn.titStr integerValue]];
            }
            return;
        }
        if (!_selectedBtn) {
            _selectedBtn = btn;
        }else{
            _selectedBtn.selected = NO;
            _selectedBtn.backgroundColor = [UIColor whiteColor];
        }
        btn.selected = !btn.selected;
        _selectedBtn = btn;
        if (btn.selected) {
            btn.backgroundColor = RGB(145,90,173);
            if (_delegate && [_delegate respondsToSelector:@selector(dynamicDidSelectIndex:)]) {
                [_delegate dynamicDidSelectIndex:[btn.titStr integerValue]];
            }
        }
    }
   
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
