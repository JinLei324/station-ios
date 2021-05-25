//
//  MainRecordMenuView.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/5/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainRecordMenuView.h"
#import "Masonry.h"
#import "RecordAiringController.h"
#import "RecordIntroduceVC.h"
#import "EMAlertView.h"

@interface MainRecordMenuView()

@property (nonatomic,strong)UIView *maskView;

///录制广播
@property (nonatomic,strong)EMButton *recordAirPortBtn;

///录制自介
@property (nonatomic,strong)EMButton *recordMySelfBtn;

///直播
@property (nonatomic,strong)EMButton *liveBtn;

@end



@implementation MainRecordMenuView

- (UIView*)maskView {
    if (!_maskView) {
        _maskView = [UIView new];
        [self addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.and.bottom.mas_equalTo(0);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (EMButton*)recordAirPortBtn {
    if (!_recordAirPortBtn) {
        _recordAirPortBtn = [EMButton new];
        [self.maskView addSubview:_recordAirPortBtn];
        [_recordAirPortBtn setBackgroundImage:[UIImage imageNamed:@"main_pop_mic"] forState:UIControlStateNormal];
        [_recordAirPortBtn setBackgroundImage:[UIImage imageNamed:@"main_pop_mic_d"] forState:UIControlStateHighlighted];
        _recordAirPortBtn.tag = 100;
        [_recordAirPortBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_recordAirPortBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(200*kScale);
            make.left.mas_equalTo(80*kScale);
            make.size.mas_equalTo(Size(79*kScale, 79*kScale));
        }];
    }
    return _recordAirPortBtn;
}


- (EMButton*)recordMySelfBtn {
    if (!_recordMySelfBtn) {
        _recordMySelfBtn = [EMButton new];
        [self.maskView addSubview:_recordMySelfBtn];
        [_recordMySelfBtn setBackgroundImage:[UIImage imageNamed:@"main_pop_me"] forState:UIControlStateNormal];
        [_recordMySelfBtn setBackgroundImage:[UIImage imageNamed:@"main_pop_me_d"] forState:UIControlStateHighlighted];
        _recordMySelfBtn.tag = 101;
        [_recordMySelfBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_recordMySelfBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(200*kScale);
            make.right.mas_equalTo(-80*kScale);
            make.size.mas_equalTo(Size(79*kScale, 79*kScale));
        }];
    }
    return _recordMySelfBtn;
}


- (EMButton*)liveBtn {
    if (!_liveBtn) {
        _liveBtn = [EMButton new];
        [self.maskView addSubview:_liveBtn];
        [_liveBtn setBackgroundImage:[UIImage imageNamed:@"main_pop_live"] forState:UIControlStateNormal];
        [_liveBtn setBackgroundImage:[UIImage imageNamed:@"main_pop_live_d"] forState:UIControlStateHighlighted];
        _liveBtn.tag = 102;
        [_liveBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_liveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.recordAirPortBtn.mas_bottom).offset(80*kScale);
            make.centerX.mas_equalTo(self.maskView);
            make.size.mas_equalTo(Size(79*kScale, 79*kScale));
        }];
    }
    return _liveBtn;
}


- (void)btnAction:(EMButton*)btn {
    NSInteger btnTag = btn.tag;
    switch (btnTag) {
        case 100:
        {
            [self tapAction];
            //录制广播
            RecordAiringController *recordAiringCtl = [[RecordAiringController alloc] init];
            UINavigationController *navV = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            [navV pushViewController:recordAiringCtl animated:YES];
            break;
        }
        case 101:
        {
            LonelyUser *user = [ViewModelCommom  getCuttentUser];
            if (user.voice.length > 0) {
                //已经录制过
                WS(weakSelf)
                AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"RecordWaring") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                    if (!cancelled) {
                        [weakSelf tapAction];
                        RecordIntroduceVC *voices = [[RecordIntroduceVC alloc] init];
                        voices.seq = 1;
                        UINavigationController *navV = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
                        [navV pushViewController:voices animated:YES];
                    }
                } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
                [alert show];
                alert = nil;
            }else {
                [self tapAction];
                //录制自介
                RecordIntroduceVC *voices = [[RecordIntroduceVC alloc] init];
                voices.seq = 1;
                UINavigationController *navV = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
                [navV pushViewController:voices animated:YES];
            }
            break;
        }
        case 102:
        {
            //直播
            [_maskView makeToast:Local(@"OntheWay") duration:ERRORTime position:[CSToastManager defaultPosition]];
            break;
        }
        default:
            break;
    }
}

- (void)tapAction {
    [_maskView removeFromSuperview];
    _maskView = nil;
    [self removeFromSuperview];
}


- (void)show {
    self.maskView.backgroundColor = RGBA(0, 0, 0, 0.5);
    self.recordAirPortBtn.hidden = NO;
    self.recordMySelfBtn.hidden = NO;
    self.liveBtn.hidden = NO;
}

@end
