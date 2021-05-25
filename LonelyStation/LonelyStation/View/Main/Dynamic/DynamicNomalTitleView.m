//
//  DynamicNomalTitleView.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/4/3.
//  Copyright © 2018年 zk. All rights reserved.
//
//  第一层title
#import "DynamicNomalTitleView.h"

@interface DynamicNomalTitleView()
@property (nonatomic,strong)EMButton *selectedBtn;
@property (nonatomic,strong)EMView *lineView;
@property (nonatomic,strong)NSMutableArray *btnArray;
@end



@implementation DynamicNomalTitleView

- (void)setTitleWithArray:(NSArray*)titleArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    for (int i = 0; i < titleArray.count; i++) {
        EMButton *titleBtn = [[EMButton alloc] initWithFrame:Rect(i*self.frame.size.width/titleArray.count, 10*kScale, self.frame.size.width/titleArray.count, 36*kScale)];
        [self addSubview:titleBtn];
        [titleBtn setTitleColor:RGB(51,51,51) forState:UIControlStateNormal];
        [titleBtn setTitleColor:RGB(51,51,51) forState:UIControlStateSelected];
        titleBtn.titleLabel.font = ComFont(15*kScale);
        titleBtn.titStr = [NSString stringWithFormat:@"%d",i];
        [titleBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        [titleBtn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [_btnArray addObject:titleBtn];
        if (i == 0) {
            titleBtn.selected = YES;
            _selectedBtn = titleBtn;
        }
    }
    _lineView = [[EMView alloc] initWithFrame:Rect(0, 46*kScale, self.frame.size.width/titleArray.count - 26*kScale , 3)];
    _lineView.backgroundColor = RGB(145,90,173);
    [self addSubview:_lineView];
    _lineView.center = CGPointMake(_selectedBtn.center.x, _lineView.center.y);
}

- (void)action:(EMButton*)btn {
    [self actionWithBool:YES andBtn:btn];
}

- (void)actionWithBool:(BOOL)isGoDelegate andBtn:(EMButton*)btn{
    if (_selectedBtn != btn) {
        if (!_selectedBtn) {
            _selectedBtn = btn;
        }else{
            _selectedBtn.selected = NO;
        }
        btn.selected = !btn.selected;
        _selectedBtn = btn;
        if (btn.selected) {
            _lineView.center = CGPointMake(_selectedBtn.center.x, _lineView.center.y);
            if (isGoDelegate) {
                if (_delegate && [_delegate respondsToSelector:@selector(dynamicNomalDidSelectIndex:andDynamicNomalTitleView:)]) {
                    [_delegate dynamicNomalDidSelectIndex:[btn.titStr integerValue] andDynamicNomalTitleView:self];
                }
            }
        }
    }
}

- (void)setSelectIndex:(int)index {
    if (_btnArray && _btnArray.count > index) {
        EMButton *btn = [_btnArray objectAtIndex:index];
        [self actionWithBool:NO andBtn:btn];
    }
}

@end
