//
//  MyVoicesVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/21.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyVoicesVC.h"
#import "UIUtil.h"
#import "UserViewModel.h"
#import "RecordIntroduceVC.h"
#import "StandViewController.h"

@interface MyVoicesVC ()

@property (nonatomic,strong)UserViewModel *userViewModel;

@property (nonatomic,strong)EMButton *myRecordBtn;

@property (nonatomic,strong)EMLabel *myRecordBtnStatus;

@property (nonatomic,strong)UIImageView *myRecordBtnStatusImgView;

@property (nonatomic,strong)EMButton *myCanRecordBtn1;

@property (nonatomic,strong)EMLabel *myCanRecordBtn1Status;

@property (nonatomic,strong)UIImageView *myCanRecordBtn1StatusImgView;


@property (nonatomic,strong)EMButton *myCanRecordBtn2;

@property (nonatomic,strong)EMLabel *myCanRecordBtn2Status;

@property (nonatomic,strong)UIImageView *myCanRecordBtn2StatusImgView;


@property (nonatomic,strong)EMButton *myCanRecordBtn3;

@property (nonatomic,strong)EMLabel *myCanRecordBtn3Status;

@property (nonatomic,strong)UIImageView *myCanRecordBtn3StatusImgView;


@property (nonatomic,strong)NSMutableArray *dataArray;


@end

@implementation MyVoicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"MyVoice")];
    [self initViews];
    // Do any additional setup after loading the view.
}


- (void)initViews {
    _userViewModel = [[UserViewModel alloc] init];
    _dataArray = [NSMutableArray array];
    EMButton *buyBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW-11-24, 28, 70*kScale, 30)];
    buyBtn.layer.borderColor = RGB(0xff, 0xff, 0xff).CGColor;
    buyBtn.layer.borderWidth = 1;
    buyBtn.layer.cornerRadius = 15;
    buyBtn.layer.masksToBounds = YES;
    
    [buyBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [buyBtn setTitle:Local(@"Complate") forState:UIControlStateNormal];
    [buyBtn addTarget:self action:@selector(complateAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:buyBtn];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH - 64)];
    
    EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect(11*kScale, 55*kScale, kScreenW - 22*kScale, 14)];
    infoLabel.text = Local(@"SuccessRecordDesp");
    infoLabel.font = ComFont(13);
    infoLabel.textColor = RGB(255,252,0);
    infoLabel.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:infoLabel];
    
    CGFloat width = 114 * kScale;
    CGFloat y = PositionY(infoLabel) + 55*kScale;
    CGFloat x = (kScreenW - width)/2.f;
    _myRecordBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, width)];
    _myRecordBtn.tag = 1;
    [_myRecordBtn setImage:[UIImage imageNamed:@"center_listen_me_big"] forState:UIControlStateNormal];
    [_myRecordBtn setImage:[UIImage imageNamed:@"center_listen_me_big_d"] forState:UIControlStateHighlighted];
    [_myRecordBtn addTarget:self action:@selector(myRecordAction:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:_myRecordBtn];
    
    _myRecordBtnStatusImgView = [[UIImageView alloc] initWithFrame:Rect(x + width - 37*kScale, y - 5*kScale, 37*kScale, 37*kScale)];
    [_myRecordBtnStatusImgView setImage:[UIImage imageNamed:@"center_add_big"]];
    [scroll addSubview:_myRecordBtnStatusImgView];
    
    _myRecordBtnStatus = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_myRecordBtn)+5*kScale, width, 14*kScale)];
    _myRecordBtnStatus.textColor = RGBA(0xff, 0xff, 0xff,0.5);
    _myRecordBtnStatus.font = ComFont(13*kScale);
    _myRecordBtnStatus.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:_myRecordBtnStatus];
    
    EMLabel *intduceLabel = [[EMLabel alloc] initWithFrame:Rect(20*kScale, PositionY(_myRecordBtnStatus)+35*kScale, kScreenW - 40*kScale, 16*kScale)];
    intduceLabel.attributedText = [EMUtil getAttributedStringWithAllStr:Local(@"PlsRecordAIntroduce") andAllBackGroudColor:RGBA(0xff, 0xff, 0xff, 0.9) andSepcialStr:Local(@"Selfintroduce") andSpecialColor:RGBA(253,125,255,0.9)];
    intduceLabel.font = ComFont(13*kScale);
    intduceLabel.textAlignment = NSTextAlignmentCenter;
    [scroll addSubview:intduceLabel];
    
    width = 96*kScale;
    x = 15*kScale;
    CGFloat space = (kScreenW - 3*width - 2*x)/2.f;
    _myCanRecordBtn1 = [[EMButton alloc] initWithFrame:Rect(x, PositionY(intduceLabel)+46*kScale, width, width)];
    _myCanRecordBtn1.tag = 2;
    [_myCanRecordBtn1 setImage:[UIImage imageNamed:@"center_sound_one_big"] forState:UIControlStateNormal];
    [_myCanRecordBtn1 setImage:[UIImage imageNamed:@"center_sound_one_big_d"] forState:UIControlStateHighlighted];
    [_myCanRecordBtn1 addTarget:self action:@selector(myRecordAction:) forControlEvents:UIControlEventTouchUpInside];

    [scroll addSubview:_myCanRecordBtn1];
    
    _myCanRecordBtn1StatusImgView = [[UIImageView alloc] initWithFrame:Rect(_myCanRecordBtn1.frame.origin.x + width - 32*kScale, _myCanRecordBtn1.frame.origin.y - 5*kScale, 32*kScale, 32*kScale)];
    [_myCanRecordBtn1StatusImgView setImage:[UIImage imageNamed:@"center_add_big"]];
    [scroll addSubview:_myCanRecordBtn1StatusImgView];
    
    _myCanRecordBtn1Status = [[EMLabel alloc] initWithFrame:Rect(_myCanRecordBtn1.frame.origin.x, PositionY(_myCanRecordBtn1)+5*kScale, width, 14*kScale)];
    _myCanRecordBtn1Status.textColor = RGBA(0xff, 0xff, 0xff,0.5);
    _myCanRecordBtn1Status.font = ComFont(13*kScale);
    _myCanRecordBtn1Status.textAlignment = NSTextAlignmentCenter;

    [scroll addSubview:_myCanRecordBtn1Status];
    
    
    _myCanRecordBtn2 = [[EMButton alloc] initWithFrame:Rect(PositionX(_myCanRecordBtn1) + space, PositionY(intduceLabel)+46*kScale, width, width)];
    _myCanRecordBtn2.tag = 3;
    [_myCanRecordBtn2 addTarget:self action:@selector(myRecordAction:) forControlEvents:UIControlEventTouchUpInside];

    [_myCanRecordBtn2 setImage:[UIImage imageNamed:@"center_sound_two_big"] forState:UIControlStateNormal];
    [_myCanRecordBtn2 setImage:[UIImage imageNamed:@"center_sound_two_big_d"] forState:UIControlStateHighlighted];
    [scroll addSubview:_myCanRecordBtn2];
    
    _myCanRecordBtn2StatusImgView = [[UIImageView alloc] initWithFrame:Rect(_myCanRecordBtn2.frame.origin.x + width - 32*kScale, _myCanRecordBtn1.frame.origin.y - 5*kScale, 32*kScale, 32*kScale)];
    [_myCanRecordBtn2StatusImgView setImage:[UIImage imageNamed:@"center_add_big"]];
    [scroll addSubview:_myCanRecordBtn2StatusImgView];
    
    
    _myCanRecordBtn2Status = [[EMLabel alloc] initWithFrame:Rect(_myCanRecordBtn2.frame.origin.x, PositionY(_myCanRecordBtn2)+5*kScale, width, 14*kScale)];
    _myCanRecordBtn2Status.textColor = RGBA(0xff, 0xff, 0xff,0.5);
    _myCanRecordBtn2Status.font = ComFont(13*kScale);
    _myCanRecordBtn2Status.textAlignment = NSTextAlignmentCenter;

    [scroll addSubview:_myCanRecordBtn2Status];
    
    _myCanRecordBtn3 = [[EMButton alloc] initWithFrame:Rect(PositionX(_myCanRecordBtn2) + space, PositionY(intduceLabel)+46*kScale, width, width)];
    _myCanRecordBtn3.tag = 4;
    [_myCanRecordBtn3 addTarget:self action:@selector(myRecordAction:) forControlEvents:UIControlEventTouchUpInside];

    [_myCanRecordBtn3 setImage:[UIImage imageNamed:@"center_sound_three_big"] forState:UIControlStateNormal];
    [_myCanRecordBtn3 setImage:[UIImage imageNamed:@"center_sound_three_big_d"] forState:UIControlStateHighlighted];
    [scroll addSubview:_myCanRecordBtn3];
    
    _myCanRecordBtn3StatusImgView = [[UIImageView alloc] initWithFrame:Rect(_myCanRecordBtn3.frame.origin.x + width - 32*kScale, _myCanRecordBtn1.frame.origin.y - 5*kScale, 32*kScale, 32*kScale)];
    [_myCanRecordBtn3StatusImgView setImage:[UIImage imageNamed:@"center_add_big"]];
    [scroll addSubview:_myCanRecordBtn3StatusImgView];
    
    _myCanRecordBtn3Status = [[EMLabel alloc] initWithFrame:Rect(_myCanRecordBtn3.frame.origin.x, PositionY(_myCanRecordBtn3)+5*kScale, width, 14*kScale)];
    _myCanRecordBtn3Status.textColor = RGBA(0xff, 0xff, 0xff,0.5);
    _myCanRecordBtn3Status.font = ComFont(13*kScale);
    _myCanRecordBtn3Status.textAlignment = NSTextAlignmentCenter;

    [scroll addSubview:_myCanRecordBtn3Status];
    
    
    EMLabel *canRecordDespLabel = [[EMLabel alloc] initWithFrame:Rect(15*kScale, PositionY(_myCanRecordBtn3)+64*kScale, kScreenW - 30*kScale, 16*kScale)];
    canRecordDespLabel.textAlignment = NSTextAlignmentCenter;
    canRecordDespLabel.attributedText = [EMUtil getAttributedStringWithAllStr:Local(@"RecordCanDesp") andAllBackGroudColor:RGBA(0xff, 0xff, 0xff, 0.9) andSepcialStr:Local(@"RecordCan") andSpecialColor:RGBA(253,125,255,0.9)];
    [scroll addSubview:canRecordDespLabel];
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(26*kScale, PositionY(canRecordDespLabel)+26*kScale, kScreenW - 52*kScale, 1)];
    line.backgroundColor = RGBA(0xff, 0xff, 0xff, 0.7);
    [scroll addSubview:line];
    
    EMButton *standDespBtn = [[EMButton alloc] initWithFrame:Rect(15*kScale, PositionY(line)+20*kScale, kScreenW - 30*kScale, 14*kScale)];
    [standDespBtn setAttributedTitle:[EMUtil getAttributedStringWithAllStr:Local(@"PlsObserveRule") andAllBackGroudColor:RGBA(0xff, 0xff, 0xff, 0.9) andSepcialStr:Local(@"Standed") andSpecialColor:RGBA(255,252,0,0.9)] forState:UIControlStateNormal];
    [standDespBtn.titleLabel setFont:ComFont(13*kScale)];
    
    [standDespBtn addTarget:self action:@selector(standAction:) forControlEvents:UIControlEventTouchUpInside];
    [scroll addSubview:standDespBtn];
    
    scroll.contentSize = Size(0, PositionY(standDespBtn)+20*kScale);
    
    [self.view addSubview:scroll];
}


- (void)standAction:(EMButton*)btn {
    StandViewController *standController = [[StandViewController alloc] init];
    standController.backStr = Local(@"IKnowAndandBack");
    [self.navigationController pushViewController:standController animated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIUtil showHUD:self.view];
    [_userViewModel getMyVoicesWithBlock:^(NSArray *array, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (array && ret) {
            [_dataArray removeAllObjects];
            [_dataArray addObjectsFromArray:array];
            [self updateBtns];
        }
    }];
}

- (void)updateBtns {
    for (int i = 0;i < _dataArray.count; i++) {
        VoiceObj *voiceObj = _dataArray[i];
        int seq = [voiceObj.voiceSeq intValue];
        int statusNum = [voiceObj.voiceStatusNum intValue];
        if (seq == 1) {
            //自介
            _myRecordBtn.titStr = voiceObj.voiceURL;
            _myRecordBtnStatus.text = voiceObj.voiceStatus;
            if (statusNum == 2) {
                _myRecordBtnStatusImgView.image = [UIImage imageNamed:@"center_finish_big"];
                _myRecordBtnStatus.textColor = RGBA(255,252,0,0.5);
            }else {
                _myRecordBtnStatusImgView.image = [UIImage imageNamed:@"center_add_big"];
                _myRecordBtnStatus.textColor = RGBA(255,255,255,0.5);
                if (statusNum == 3) {
                    _myRecordBtnStatus.textColor = RGBA(255,105,105,0.5);
                }
            }
        }else if(seq == 2){
            //罐头音1
            _myCanRecordBtn1.titStr = voiceObj.voiceURL;
            _myCanRecordBtn1Status.text = voiceObj.voiceStatus;
            if (statusNum == 2) {
                _myCanRecordBtn1StatusImgView.image = [UIImage imageNamed:@"center_finish_big"];
                _myCanRecordBtn1Status.textColor = RGBA(255,252,0,0.5);
            }else {
                _myCanRecordBtn1StatusImgView.image = [UIImage imageNamed:@"center_add_big"];
                _myCanRecordBtn1Status.textColor = RGBA(255,255,255,0.5);
                if (statusNum == 3) {
                    _myCanRecordBtn1Status.textColor = RGBA(255,105,105,0.5);
                }
            }
        }else if (seq == 3){
            //罐头音2
            _myCanRecordBtn2.titStr = voiceObj.voiceURL;
            _myCanRecordBtn2Status.text = voiceObj.voiceStatus;
            if (statusNum == 2) {
                _myCanRecordBtn2StatusImgView.image = [UIImage imageNamed:@"center_finish_big"];
                _myCanRecordBtn2Status.textColor = RGBA(255,252,0,0.5);
            }else {
                _myCanRecordBtn2StatusImgView.image = [UIImage imageNamed:@"center_add_big"];
                _myCanRecordBtn2Status.textColor = RGBA(255,255,255,0.5);
                if (statusNum == 3) {
                    _myCanRecordBtn2Status.textColor = RGBA(255,105,105,0.5);
                }
            }
        }else if (seq == 4){
            //罐头音3
            _myCanRecordBtn3.titStr = voiceObj.voiceURL;
            _myCanRecordBtn3Status.text = voiceObj.voiceStatus;
            if (statusNum == 2) {
                _myCanRecordBtn3StatusImgView.image = [UIImage imageNamed:@"center_finish_big"];
                _myCanRecordBtn3Status.textColor = RGBA(255,252,0,0.5);
            }else {
                _myCanRecordBtn3StatusImgView.image = [UIImage imageNamed:@"center_add_big"];
                _myCanRecordBtn3Status.textColor = RGBA(255,255,255,0.5);
                if (statusNum == 3) {
                    _myCanRecordBtn3Status.textColor = RGBA(255,105,105,0.5);
                }
            }
        }
    }
}


- (void)myRecordAction:(EMButton*)btn {
    if(btn.titStr && btn.titStr.length>0){
        AllPopView *alertView = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"RecordWaring") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                RecordIntroduceVC *recordIntVC = [[RecordIntroduceVC alloc] init];
                recordIntVC.seq = (int)btn.tag;
                [self.navigationController pushViewController:recordIntVC animated:YES];
            }
        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
        [alertView show];
        alertView = nil;
    }else {
        RecordIntroduceVC *recordIntVC = [[RecordIntroduceVC alloc] init];
        recordIntVC.seq = (int)btn.tag;
        [self.navigationController pushViewController:recordIntVC animated:YES];
    }

}



- (void)complateAction:(EMButton*)btn {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
