//
//  UserChargeSettingView.m
//  LonelyStation
//
//  Created by 钟铿 on 2017/12/25.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "UserChargeSettingView.h"
#import "Masonry.h"

@interface UserChargeSettingView()

@property(nonatomic,strong)EMView *chatBackView;

@property(nonatomic,strong)EMView *msgBackView;

@property(nonatomic,strong)EMView *chatSelectView;

@property(nonatomic,strong)EMView *msgSelectView;

@property(nonatomic,weak)EMButton *msgSelectedBtn;

@property(nonatomic,weak)EMButton *chatSelectedBtn;


@end

@implementation UserChargeSettingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self initWithSize:frame.size];
    return self;
}

- (void)initWithSize:(CGSize)size {
    _chatBackView = [EMView new];
    [self addSubview:_chatBackView];
    [_chatBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.mas_equalTo(0);
        make.height.mas_equalTo(41*kScale);
    }];
    
    _chatSelectView = [EMView new];
    [self addSubview:_chatSelectView];
    [_chatSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_chatBackView.mas_bottom);
        make.height.mas_equalTo(0);
        make.left.and.right.mas_equalTo(0);
    }];
    NSArray *titleArray = @[Local(@"SixtyChatMoney"),Local(@"OneHundredTwentyChatMoney"),Local(@"OneHundredEighttyChatMoney"),Local(@"MsgChatMoney1"),Local(@"MsgChatMoney2"),Local(@"MsgChatMoney3")];
    NSArray *titleChargeArray = @[@"60",@"120",@"180",@"12",@"24",@"36"];
    for(int i = 0;i < 3;i++){
        EMButton *btn = [[EMButton alloc] initWithFrame:Rect(26*kScale, 44*kScale*i, kScreenW - 52*kScale, 43*kScale)];
        [btn setImage:[UIImage imageNamed:@"singlenoButton"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"singleyesButton"] forState:UIControlStateSelected];
        [btn setTitle:titleArray[i] forState:UIControlStateNormal];
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10*kScale, 0, 0);
        [btn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
        btn.titleLabel.font = ComFont(16*kScale);
        [btn addTarget:self action:@selector(chatBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.titStr = titleChargeArray[i];
        [_chatSelectView addSubview:btn];
        btn.hidden = YES;
    }

    _msgBackView = [EMView new];
    [self addSubview:_msgBackView];
    [_msgBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_chatSelectView.mas_bottom);
        make.height.mas_equalTo(41*kScale);
        make.left.and.right.mas_equalTo(0);
    }];
    
    _msgSelectView = [EMView new];
    [self addSubview:_msgSelectView];
    [_msgSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_msgBackView.mas_bottom);
        make.height.mas_equalTo(0);
        make.left.and.right.mas_equalTo(0);
    }];
    
    for(int i = 0;i < 3;i++){
        EMButton *btn = [[EMButton alloc] initWithFrame:Rect(26*kScale, 44*kScale*i, kScreenW - 52*kScale, 43*kScale)];
        [btn setImage:[UIImage imageNamed:@"singlenoButton"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"singleyesButton"] forState:UIControlStateSelected];
        [btn setTitle:titleArray[i+3] forState:UIControlStateNormal];
        [btn setTitleColor:RGB(145,90,173) forState:UIControlStateNormal];
        btn.titleLabel.font = ComFont(16*kScale);
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 10*kScale, 0, 0);
        [btn addTarget:self action:@selector(msgBtnSelect:) forControlEvents:UIControlEventTouchUpInside];
        btn.titStr = titleChargeArray[i+3];
        [_msgSelectView addSubview:btn];
        btn.hidden = YES;
    }
    
    _chatlabel = [[EMLabel alloc] initWithFrame:Rect(26*kScale, 0, 190*kScale, 40*kScale)];
    _chatlabel.textColor = RGB(51, 51, 51);
    _chatlabel.font = ComFont(14*kScale);
    _chatlabel.text = Local(@"CallCharge");
    [_chatBackView addSubview:_chatlabel];
    _chatSwitchBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 64 *kScale, 9*kScale, 43*kScale, 21*kScale)];
    _chatSwitchBtn.titStr = @"chat";
    [_chatSwitchBtn setImage:[UIImage imageNamed:@"set_on"] forState:UIControlStateNormal];
    [_chatSwitchBtn setImage:[UIImage imageNamed:@"set_off"] forState:UIControlStateSelected];
    [_chatSwitchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [_chatBackView addSubview:_chatSwitchBtn];
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 40*kScale, kScreenW, 1)];
    line.backgroundColor = RGB(171,171,171);
    [_chatBackView addSubview:line];
    
    _msglabel = [[EMLabel alloc] initWithFrame:Rect(26*kScale, 0, 190*kScale, 40*kScale)];
    _msglabel.textColor = RGB(51, 51, 51);
    _msglabel.font = ComFont(14*kScale);
    _msglabel.text = Local(@"MsgCharge");
    [_msgBackView addSubview:_msglabel];
    _msgSwitchBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 64 *kScale, 9*kScale, 43*kScale, 21*kScale)];
    _msgSwitchBtn.titStr = @"msg";
    [_msgSwitchBtn setImage:[UIImage imageNamed:@"set_on"] forState:UIControlStateNormal];
    [_msgSwitchBtn setImage:[UIImage imageNamed:@"set_off"] forState:UIControlStateSelected];
    [_msgSwitchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    [_msgBackView addSubview:_msgSwitchBtn];
    
}

- (void)setChatSwithchOn:(BOOL)isOn {
    _chatSwitchBtn.selected = isOn;
    [self setSubViewsHidden:_chatSelectView andHidden:isOn];
    [_chatSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (!isOn) {
            make.height.mas_equalTo(132*kScale);
        }else{
            make.height.mas_equalTo(0);
        }
    }];
}


- (void)chatBtnSelect:(EMButton*)btn {
    if (_chatSelectedBtn != btn) {
        if (!_chatSelectedBtn) {
            _chatSelectedBtn = btn;
        }else{
            _chatSelectedBtn.selected = NO;
        }
        btn.selected = !btn.selected;
        _chatSelectedBtn = btn;
        if (_aDelegate && [_aDelegate respondsToSelector:@selector(didSelectchatChargeChildAction:)]) {
            [_aDelegate didSelectchatChargeChildAction:btn.titStr];
        }
    }
}

- (void)msgBtnSelect:(EMButton*)btn {
    if (_msgSelectedBtn != btn) {
        if (!_msgSelectedBtn) {
            _msgSelectedBtn = btn;
        }else{
            _msgSelectedBtn.selected = NO;
        }
        btn.selected = !btn.selected;
        _msgSelectedBtn = btn;
        if (_aDelegate && [_aDelegate respondsToSelector:@selector(didSelectmsgChargeChildAction:)]) {
            [_aDelegate didSelectmsgChargeChildAction:btn.titStr];
        }
    }
}

- (void)setSubViewsHidden:(UIView*)motherView andHidden:(BOOL)isHidden {
    for (int i = 0; i < motherView.subviews.count; i++) {
        EMButton *aBtn = motherView.subviews[i];
        [aBtn setHidden:isHidden];
    }
}


- (void)setMsgSwithchOn:(BOOL)isOn {
    _msgSwitchBtn.selected = isOn;
    [self setSubViewsHidden:_msgSelectView andHidden:isOn];
    [_msgSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (!isOn) {
            make.height.mas_equalTo(132*kScale);
        }else{
            make.height.mas_equalTo(0);
        }
    }];
}

- (void)setChatChildSelect:(NSString*)chatCharge {
    int index = 0;
    if ([chatCharge isEqualToString:@"60"]) {
        index = 0;
    }else if ([chatCharge isEqualToString:@"120"]){
        index = 1;
    }else if ([chatCharge isEqualToString:@"180"]) {
        index = 2;
    }
    for (int i = 0; i < _chatSelectView.subviews.count; i++) {
        EMButton *aBtn = _chatSelectView.subviews[i];
        if (i == index) {
            aBtn.selected = YES;
            _chatSelectedBtn = aBtn;
        }else{
            aBtn.selected = NO;
        }
    }
}


- (void)setMsgChildSelect:(NSString*)chatCharge {
    int index = 0;
    if ([chatCharge isEqualToString:@"12"]) {
        index = 0;
    }else if ([chatCharge isEqualToString:@"24"]){
        index = 1;
    }else if ([chatCharge isEqualToString:@"36"]) {
        index = 2;
    }
    for (int i = 0; i < _msgSelectView.subviews.count; i++) {
        EMButton *aBtn = _msgSelectView.subviews[i];
        if (i == index) {
            aBtn.selected = YES;
            _msgSelectedBtn = aBtn;
        }else{
            aBtn.selected = NO;
        }
    }
}


- (void)switchAction:(EMButton*)btn {
    btn.selected = !btn.selected;
    if ([btn.titStr isEqualToString:@"msg"]) {
        [self setSubViewsHidden:_msgSelectView andHidden:!btn.selected];
        [_msgSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (btn.selected) {
                make.height.mas_equalTo(132*kScale);
            }else{
                make.height.mas_equalTo(0);
            }
        }];
        if (_aDelegate && [_aDelegate respondsToSelector:@selector(didSelectmsgChargeAction:)]) {
            [_aDelegate didSelectmsgChargeAction:btn.isSelected];
        }
      
    }else {
        [self setSubViewsHidden:_chatSelectView andHidden:!btn.selected];
        [_chatSelectView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (btn.selected) {
                make.height.mas_equalTo(132*kScale);
            }else{
                make.height.mas_equalTo(0);
            }
        }];
        if (_aDelegate && [_aDelegate respondsToSelector:@selector(didSelectCallChargeAction:)]) {
            [_aDelegate didSelectCallChargeAction:btn.isSelected];
        }
      
    }
   
}
@end
