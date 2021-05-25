//
//  ChargePointViewController.m
//  LonelyStation
//
//  Created by 钟铿 on 2019/1/27.
//  Copyright © 2019 zk. All rights reserved.
//

#import "ChargePointViewController.h"
#import "ViewModelCommom.h"
#import "UIUtil.h"
#import "ChargeVM.h"

@interface ChargePointViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic,strong)UILabel *desLabel;
@property (nonatomic,strong)UIImageView  *firstView;
@property (nonatomic,strong)UIImageView  *secondView;

@property (nonatomic,strong)UILabel *leftCoinLabel;
@property (nonatomic,strong)UILabel *withDrawCoinLabel;
@property (nonatomic,strong)UIButton *addLeftCoinBtn;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)UIButton *addWithDrawCoinBtn;
@property (nonatomic,strong)ChargeVM *chargeVM;


@end

@implementation ChargePointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
    // Do any additional setup after loading the view.
}

- (void)initViews {
    [self.viewNaviBar setTitle:Local(@"Change") andColor:RGB(145,90,173)];
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    [buyBtn setBackgroundColor:RGB(209,172,255)];
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Sure") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(complateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    
    self.firstView.image = [UIImage imageNamed:@"withdraw_bg"];
    self.secondView.image = [UIImage imageNamed:@"withdraw_bg"];
    self.desLabel.text = Local(@"ChargeDes");

    self.leftCoinLabel.text = self.leftCoin;
    self.withDrawCoinLabel.text = self.withDrawCoin;
    [self.addLeftCoinBtn addTarget:self action:@selector(addLeftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.addWithDrawCoinBtn addTarget:self action:@selector(addWithDrawAction:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void)addLeftAction:(UIButton*)btn {
    [self minusLeftValueChange:1];
}

- (void)addWithDrawAction:(UIButton*)btn {
    [self minusValueChange:1];
}

- (void)complateAction:(UIButton*)btn {
    [UIUtil showHUD:self.view];
    WS(weakSelf);
    [self.chargeVM chargeWithLeftCoin:self.leftCoinLabel.text andRightCoin:self.withDrawCoinLabel.text andBlock:^(NSDictionary * _Nonnull dict, BOOL ret) {
        [UIUtil hideHUD:weakSelf.view];
        if (ret) {
//             [self.superview.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            [weakSelf.view makeToast:Local(@"OperateSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }else{
            [weakSelf.view makeToast:dict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

- (ChargeVM*)chargeVM {
    if (!_chargeVM) {
        _chargeVM = [ChargeVM new];
    }
    return _chargeVM;
}

- (UIImageView*)firstView {
    if (!_firstView) {
        _firstView = [UIImageView new];
        [self.view addSubview:_firstView];
        [_firstView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(0);
            make.top.mas_equalTo(StatusBarHeight+44);
            make.height.mas_equalTo(100*kScale);
        }];
        _firstView.userInteractionEnabled = YES;
    }
    return _firstView;
}


- (UIImageView*)secondView {
    if (!_secondView) {
        _secondView = [UIImageView new];
        [self.view addSubview:_secondView];
        [_secondView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.mas_equalTo(0);
            make.top.equalTo(self.firstView.mas_bottom).offset(10);
            make.height.mas_equalTo(100*kScale);
        }];
        _secondView.userInteractionEnabled = YES;
    }
    return _secondView;
}

- (UILabel*)desLabel {
    if (!_desLabel) {
        _desLabel = [UILabel new];
        [self.view addSubview:_desLabel];
        [_desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.mas_equalTo(0);
            make.height.mas_greaterThanOrEqualTo(44*kScale);
        }];
        UIView *line = [UIView new];
        [_desLabel addSubview:line];
        line.backgroundColor = RGB(171, 171, 171);
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.top.and.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        _desLabel.font = ComFont(14);
        _desLabel.textColor = RGB(51, 51, 51);
        _desLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _desLabel;
}

- (UILabel*)leftCoinLabel {
    if (!_leftCoinLabel) {
        UILabel *label = [UILabel new];
        [self.firstView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(26*kScale);
            make.right.equalTo(self.firstView.mas_centerX);
        }];
        label.textAlignment = NSTextAlignmentRight;
        label.font = ComFont(16);
        label.textColor = RGB(0xff, 0xff, 0xff);
        label.text = Local(@"LeftCoin");
        _leftCoinLabel = [UILabel new];
        [self.firstView addSubview:_leftCoinLabel];
        [_leftCoinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).offset(10*kScale);
            make.right.mas_equalTo(label.mas_right);
            make.width.mas_greaterThanOrEqualTo(60*kScale);
        }];
        _leftCoinLabel.textAlignment = NSTextAlignmentCenter;
        _leftCoinLabel.font = ComFont(18);
        _leftCoinLabel.textColor = RGB(0xff, 0xff, 0xff);
        
    }
    return _leftCoinLabel;
}


- (UILabel*)withDrawCoinLabel {
    if (!_withDrawCoinLabel) {
        UILabel *label = [UILabel new];
        [self.secondView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(26*kScale);
            make.right.equalTo(self.firstView.mas_centerX);
            make.width.mas_greaterThanOrEqualTo(60*kScale);
        }];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = ComFont(16);
        label.textColor = RGB(0xff, 0xff, 0xff);
        label.text = Local(@"CanWithDraw");
        _withDrawCoinLabel = [UILabel new];
        [self.secondView addSubview:_withDrawCoinLabel];
        [_withDrawCoinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).offset(10*kScale);
            make.right.mas_equalTo(label.mas_right);
            make.width.mas_greaterThanOrEqualTo(60*kScale);
        }];
        _withDrawCoinLabel.textAlignment = NSTextAlignmentCenter;
        _withDrawCoinLabel.font = ComFont(18);
        _withDrawCoinLabel.textColor = RGB(0xff, 0xff, 0xff);
        
    }
    return _withDrawCoinLabel;
}


-(UIButton*)addLeftCoinBtn {
    if (!_addLeftCoinBtn) {
        _addLeftCoinBtn = [UIButton new];
        [self.firstView addSubview:_addLeftCoinBtn];
        [_addLeftCoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.firstView.mas_centerX).offset(10*kScale);
            make.centerY.equalTo(self.firstView);
            make.size.mas_equalTo(Size(44*kScale, 41*kScale));
        }];
        [_addLeftCoinBtn setImage:[UIImage imageNamed:@"withdrawal_add_d"] forState:UIControlStateNormal];
        UILongPressGestureRecognizer *longPressGuesForMinus = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(minusButtonLeftLongPressed:)];
        longPressGuesForMinus.allowableMovement = 50;
        longPressGuesForMinus.delegate = self;
        [_addLeftCoinBtn addGestureRecognizer:longPressGuesForMinus];
    }
    return _addLeftCoinBtn;
}

-(UIButton*)addWithDrawCoinBtn {
    if (!_addWithDrawCoinBtn) {
        _addWithDrawCoinBtn = [UIButton new];
        [self.secondView addSubview:_addWithDrawCoinBtn];
        [_addWithDrawCoinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.secondView.mas_centerX).offset(10*kScale);
            make.centerY.equalTo(self.self.secondView);
            make.size.mas_equalTo(Size(44*kScale, 41*kScale));
        }];
        [_addWithDrawCoinBtn setImage:[UIImage imageNamed:@"withdrawal_add_d"] forState:UIControlStateNormal];
        UILongPressGestureRecognizer *longPressGuesForMinus = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(minusButtonLongPressed:)];
        longPressGuesForMinus.allowableMovement = 50;
        longPressGuesForMinus.delegate = self;
        [_addWithDrawCoinBtn addGestureRecognizer:longPressGuesForMinus];
    }
    return _addWithDrawCoinBtn;
}

- (void)minusButtonLongPressed:(UILongPressGestureRecognizer *)guesture {
    BOOL flag = YES;
    if (guesture.state == UIGestureRecognizerStateEnded || guesture.state == UIGestureRecognizerStateFailed) {
        flag = NO;
    }
    if (flag) {
        if (!self.timer) {
            WS(weakSelf);
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [weakSelf minusValueChange:100];
            }];
        }
        [self.timer fire];
    }
    if (!flag) {
        if (self.timer.isValid) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
    
}

- (void)minusButtonLeftLongPressed:(UILongPressGestureRecognizer *)guesture {
    BOOL flag = YES;
    if (guesture.state == UIGestureRecognizerStateEnded || guesture.state == UIGestureRecognizerStateFailed) {
        flag = NO;
    }
    if (flag) {
        if (!self.timer) {
            WS(weakSelf);
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
                [weakSelf minusLeftValueChange:100];
            }];
        }
        [self.timer fire];
    }
    if (!flag) {
        if (self.timer.isValid) {
            [self.timer invalidate];
            self.timer = nil;
        }
    }
}


- (void)minusLeftValueChange:(int)step {
    NSInteger value = [self.withDrawCoinLabel.text integerValue]-step;
    NSInteger otherValue = [self.leftCoinLabel.text integerValue] + step;
    if (value>0) {
        self.leftCoinLabel.text = [NSString stringWithFormat:@"%ld", otherValue];
        self.withDrawCoinLabel.text = [NSString stringWithFormat:@"%ld", value];
    }
}

- (void)minusValueChange:(int)step {
    NSInteger value = [self.leftCoinLabel.text integerValue]-step;
    NSInteger otherValue = [self.withDrawCoinLabel.text integerValue] + step;
    if (value>0) {
        self.withDrawCoinLabel.text = [NSString stringWithFormat:@"%ld", otherValue];
        self.leftCoinLabel.text = [NSString stringWithFormat:@"%ld", value];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
