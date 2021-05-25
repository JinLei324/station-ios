//
//  AdvancedSearchVC.m
//  LonelyStation
//
//  Created by zk on 16/10/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AdvancedSearchVC.h"
#import "UIUtil.h"
#import "NMRangeSlider.h"
#import "EMActionSheet.h"
#import "LonelyCountry.h"
#import "LonelyCity.h"
#import "JobObj.h"
#import "MainViewVM.h"
#import "MainViewController.h"
#import "ViewModelCommom.h"
#import "AllStationNewVC.h"

@interface AdvancedSearchVC()

@property (nonatomic,strong)NMRangeSlider *nmSlider;
@property (nonatomic,strong)EMView *nmline;

@property (nonatomic,assign)int startAge;
@property (nonatomic,assign)int endAge;
@property (nonatomic,strong)EMLabel *ageLabel;
@property (nonatomic,strong)EMButton *onlineStatusBtn;
@property (nonatomic,strong)EMButton *chargeStatusBtn;
@property (nonatomic,strong)EMButton *roleBtn;
@property (nonatomic,strong)EMButton *languageBtn;
@property (nonatomic,strong)EMButton *cityBtn;
@property (nonatomic,strong)EMButton *jobBtn;
@property (nonatomic,strong)EMTextField *nickNameTextField;



@property (nonatomic,copy)NSString *onlineStr;
@property (nonatomic,copy)NSString *chargeStr;
@property (nonatomic,copy)NSString *identityStr;
@property (nonatomic,copy)NSString *spkLangStr;
@property (nonatomic,copy)NSString *cityStr;
@property (nonatomic,copy)NSString *jobStr;
@property (nonatomic,strong)LonelySpkLang *currentLang;
@property (nonatomic,strong)LonelyCity *currentCity;
@property (nonatomic,strong)JobObj *currentJob;

@property (nonatomic,strong)MainViewVM *mainViewVM;
@property (nonatomic,strong)NSMutableArray *languageArray;
@property (nonatomic,strong)NSMutableArray *cityArray;
@property (nonatomic,strong)NSMutableArray *jobArray;

@end

@implementation AdvancedSearchVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setTitle:Local(@"AdvancedSearch") andColor:RGB(145,90,173)];
    [self initViews];
}

- (void)initViews {
    _mainViewVM = [[MainViewVM alloc] init];
    _onlineStr = @"";
    _identityStr = @"";
    _spkLangStr = @"";
    _cityStr = @"";
    _jobStr = @"";
    
    //确定按钮
    EMButton *sureBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 49*kScale - 15 , 30, 49*kScale, 25*kScale) andConners:9*kScale];
    [sureBtn setBackgroundColor:RGB(145,90,173)];
    [sureBtn setBorderColor:RGB(255,255,255)];
    [sureBtn setBorderWidth:1];
    [sureBtn setTitle:Local(@"Sure") forState:UIControlStateNormal];
    [sureBtn setTitleColor:RGB(255,255,255) forState:UIControlStateNormal];
    [sureBtn.titleLabel setFont:ComFont(15)];

    [sureBtn addTarget:self action:@selector(sureAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar addSubview:sureBtn];
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    [self.view addSubview:scroll];
    
    //昵称
    _nickNameTextField = [[EMTextField alloc] initWithFrame:Rect(25*kScale, 28*kScale, kScreenW - 50*kScale, 33*kScale)];
    [_nickNameTextField setBackgroundColor:RGB(222, 222, 222)];
    _nickNameTextField.layer.cornerRadius = 20;
    _nickNameTextField.layer.masksToBounds = YES;
    _nickNameTextField.textAlignment = NSTextAlignmentCenter;
    _nickNameTextField.tintColor = RGB(51, 51, 51);
    _nickNameTextField.textColor = RGB(51, 51, 51);
    [scroll addSubview:_nickNameTextField];
    
    //搜寻的年龄
    EMLabel *searchAge = [[EMLabel alloc] initWithFrame:Rect(17*kScale,PositionY(_nickNameTextField) + 25 * kScale, 120*kScale, 16*kScale)];
    searchAge.text = Local(@"SearchAge");
    searchAge.textColor = RGB(51, 51, 51);
    searchAge.font = ComFont(15*kScale);
    [scroll addSubview:searchAge];
    
    
    CGFloat x = 19*kScale;
    CGFloat y = PositionY(searchAge) + 25 * kScale;
    CGFloat width = kScreenW - 2*19*kScale;
    CGFloat height = 31*kScale;
    
    _nmSlider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(x,y,width,height)];
    _nmSlider.lowerValue = 0;
    _nmSlider.upperValue = 1;
    
    UIImage *image = [UIImage imageNamed:@"cut_dot"];
    _nmSlider.lowerHandleImageNormal = image;
    _nmSlider.upperHandleImageNormal = image;
    
    _nmSlider.trackImage =  [UIUtil imageWithColor:RGB(253,125,255) andSize:CGSizeMake(5, 3)];
    _nmline = [[EMView alloc] initWithFrame:CGRectMake(x, _nmSlider.frame.origin.y + height/2.f - 0.5, width, 2)];
    _nmline.backgroundColor = RGBA(171, 171, 171, 1);
    [scroll addSubview:_nmline];
    [scroll addSubview:_nmSlider];
    [_nmSlider addObserver:self forKeyPath:@"lowerValue" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [_nmSlider addObserver:self forKeyPath:@"upperValue" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    //年龄的label
    width = 150;
    _startAge = 18;
    _endAge = 99;
    _ageLabel = [[EMLabel alloc] initWithFrame:Rect(kScreenW - width -x, PositionY(searchAge) + 15*kScale , width, 15*kScale)];
    
    _ageLabel.text = [NSString stringWithFormat:@"%d%@~%d%@",_startAge,Local(@"Year"),_endAge,Local(@"Year")];
    _ageLabel.font = ComFont(15*kScale);
    _ageLabel.textColor = RGB(51,51,51);
    _ageLabel.textAlignment = NSTextAlignmentRight;
    [scroll addSubview:_ageLabel];
    
    //上线状态
    EMLabel *onlineStatus = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(_nmSlider)+50*kScale, 120*kScale, 16*kScale)];
    onlineStatus.text = Local(@"OnlineStatus");
    onlineStatus.textColor = RGB(51, 51, 51);
    onlineStatus.font = ComFont(15*kScale);
    [scroll addSubview:onlineStatus];
    
    _onlineStatusBtn = [UIUtil createWhiteBtnWithFrame:Rect(25*kScale, PositionY(onlineStatus)+15*kScale, kScreenW - 50*kScale, 33*kScale) andTitle:Local(@"StatusDefault") andSelector:@selector(statusAction:) andTarget:self];
    [scroll addSubview:_onlineStatusBtn];
    _onlineStr = @"";
    
    //收费状态
    EMLabel *chargeStatus = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(_onlineStatusBtn)+15*kScale, 120*kScale, 16*kScale)];
    chargeStatus.text = Local(@"ChargeStatus");
    chargeStatus.textColor = RGB(51, 51, 51);
    chargeStatus.font = ComFont(15*kScale);
    [scroll addSubview:chargeStatus];
    
    _chargeStatusBtn = [UIUtil createWhiteBtnWithFrame:Rect(25*kScale, PositionY(chargeStatus)+15*kScale, kScreenW - 50*kScale, 33*kScale) andTitle:Local(@"StatusDefault") andSelector:@selector(chargeAction:) andTarget:self];
    [scroll addSubview:_chargeStatusBtn];
    _chargeStr = @"";
    
    //身份别
    EMLabel *roleLabel = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(_chargeStatusBtn)+15*kScale, 120*kScale, 16*kScale)];
    roleLabel.text = Local(@"Role");
    roleLabel.textColor = RGB(51, 51, 51);
    roleLabel.font = ComFont(15*kScale);
    [scroll addSubview:roleLabel];
    
    _roleBtn = [UIUtil createWhiteBtnWithFrame:Rect(25*kScale, PositionY(roleLabel)+15*kScale, kScreenW - 50*kScale, 33*kScale) andTitle:Local(@"StatusDefault") andSelector:@selector(roleAction:) andTarget:self];
    [scroll addSubview:_roleBtn];
    _identityStr = @"";
    
    //语言
    EMLabel *laguageLabel = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(_roleBtn)+15*kScale, 120*kScale, 16*kScale)];
    laguageLabel.text = [NSString stringWithFormat:@"%@:",Local(@"Lang")];
    laguageLabel.textColor = RGB(51, 51, 51);
    laguageLabel.font = ComFont(15*kScale);
    [scroll addSubview:laguageLabel];
    
    _languageBtn = [UIUtil createWhiteBtnWithFrame:Rect(25*kScale, PositionY(laguageLabel)+15*kScale, kScreenW - 50*kScale, 33*kScale) andTitle:Local(@"LanguageDefault") andSelector:@selector(laguageAction:) andTarget:self];
    [scroll addSubview:_languageBtn];
    
    //城市
    EMLabel *cityLabel = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(_languageBtn)+15*kScale, 120*kScale, 16*kScale)];
    cityLabel.text = [NSString stringWithFormat:@"%@:",Local(@"City")];
    cityLabel.textColor = RGB(51, 51, 51);
    cityLabel.font = ComFont(15*kScale);
    [scroll addSubview:cityLabel];
    
    _cityBtn = [UIUtil createWhiteBtnWithFrame:Rect(25*kScale, PositionY(cityLabel)+15*kScale, kScreenW - 50*kScale, 33*kScale) andTitle:Local(@"CityDefault") andSelector:@selector(cityAction:) andTarget:self];
    [scroll addSubview:_cityBtn];
    
    //职业
    EMLabel *jobLabel = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(_cityBtn)+15*kScale, 120*kScale, 16*kScale)];
    jobLabel.text = [NSString stringWithFormat:@"%@:",Local(@"Job")];
    jobLabel.textColor = RGB(51, 51, 51);
    jobLabel.font = ComFont(15*kScale);
    [scroll addSubview:jobLabel];
    
    _jobBtn = [UIUtil createWhiteBtnWithFrame:Rect(25*kScale, PositionY(jobLabel)+15*kScale, kScreenW - 50*kScale, 33*kScale) andTitle:Local(@"StatusDefault") andSelector:@selector(jobAction:) andTarget:self];
    [scroll addSubview:_jobBtn];
    
    [scroll setContentSize:Size(0, PositionY(_jobBtn) + 20)];
}

//职业
- (void)jobAction:(EMButton*)btn {
    if (!_jobArray) {
        [self getJobAndShow:btn];
    }else {
        if (_jobArray.count == 0) {
            [self getJobAndShow:btn];
        }else {
            [self showJobSheet:btn];
        }
    }
}

//获取职业和显示
- (void)getJobAndShow:(EMButton*)btn {
    [UIUtil showHUD:self.view];
    [_mainViewVM getJobListWithBlock:^(NSArray<JobObj *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _jobArray = nil;
            _jobArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showJobSheet:btn];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示职业列表
- (void)showJobSheet:(EMButton*)btn {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Job") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            JobObj *job = _jobArray[buttonIndex-1];
            _currentJob = job;
            _jobStr = job.jobId;
            [btn setTitle:job.jobName forState:UIControlStateNormal];
        }else {
            _currentJob = nil;
            _jobStr = @"";
            [btn setTitle:Local(@"StatusDefault") forState:UIControlStateNormal];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _jobArray.count; i++) {
        JobObj *job = _jobArray[i];
        [sheet addButtonWithTitle:job.jobName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//城市
- (void)cityAction:(EMButton*)btn {
    if (!_cityArray) {
        [self getCityAndShow:btn];
    }else {
        if (_cityArray.count == 0) {
            [self getCityAndShow:btn];
        }else {
            [self showCitySheet:btn];
        }
    }
}

//获取城市和显示
- (void)getCityAndShow:(EMButton*)btn {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [UIUtil showHUD:self.view];
    [_mainViewVM getCityListByCountryId:user.countryId andBlock:^(NSArray<LonelyCity *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _cityArray = nil;
            _cityArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showCitySheet:btn];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示城市列表
- (void)showCitySheet:(EMButton*)btn {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"City") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyCity *city = _cityArray[buttonIndex-1];
            _currentCity = city;
            _cityStr = city.cityId;
            [btn setTitle:city.cityName forState:UIControlStateNormal];
        }else {
            _currentCity = nil;
            _cityStr = @"";
            [btn setTitle:Local(@"CityDefault") forState:UIControlStateNormal];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _cityArray.count; i++) {
        LonelyCity *city = _cityArray[i];
        [sheet addButtonWithTitle:city.cityName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}


//获取语言和显示
- (void)getLanguageListAndShow:(EMButton*)btn {
    [UIUtil showHUD:self.view];
    [_mainViewVM getLangspkWithBlock:^(NSArray<LonelySpkLang *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _languageArray = nil;
            _languageArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showLanguageSheet:btn];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示语言列表
- (void)showLanguageSheet:(EMButton*)btn {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Lang") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelySpkLang *lang = _languageArray[buttonIndex-1];
            _currentLang = lang;
            _spkLangStr = lang.langId;
            [btn setTitle:lang.langName forState:UIControlStateNormal];
        }else {
            _currentLang = nil;
            _spkLangStr = @"";
            [btn setTitle:Local(@"LanguageDefault") forState:UIControlStateNormal];
        }
        
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _languageArray.count; i++) {
        LonelySpkLang *country = _languageArray[i];
        [sheet addButtonWithTitle:country.langName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//语言
- (void)laguageAction:(EMButton*)btn {
    if (!_languageArray) {
        [self getLanguageListAndShow:btn];
    }else {
        if (_languageArray.count == 0) {
            [self getLanguageListAndShow:btn];
        }else {
            [self showLanguageSheet:btn];
        }
    }
}


//身份别
- (void)roleAction:(EMButton*)btn {
    NSArray *array = @[Local(@"RoleDefault"),Local(@"Secreter"),Local(@"Voicer")];
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"OnlineStatus") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (cancelled) {
            _identityStr = @"";
            [btn setTitle:array[0] forState:UIControlStateNormal];
        }else{
            if (buttonIndex == 1) {
                _identityStr = @"3";
            }else {
                _identityStr = [NSString stringWithFormat:@"%d",(int)buttonIndex-1];
            }
            [btn setTitle:array[buttonIndex-1] forState:UIControlStateNormal];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"RoleDefault"),Local(@"Secreter"),Local(@"Voicer"),nil];
    [sheet showInView:self.view];
    sheet = nil;
}
//收费状态
- (void)chargeAction:(EMButton*)btn {
    NSArray *array = @[Local(@"StatusDefault"),Local(@"Charge"),Local(@"Free")];
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"ChargeStatus") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (cancelled) {
            _chargeStr = @"";
            [btn setTitle:array[0] forState:UIControlStateNormal];
        }else{
            if (buttonIndex == 1) {
                _chargeStr = @"Y";
            }else {
                _chargeStr = @"N";
            }
            [btn setTitle:array[buttonIndex] forState:UIControlStateNormal];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"Charge"),Local(@"Free"),nil];
    [sheet showInView:self.view];
    sheet = nil;
}

//上线状态
- (void)statusAction:(EMButton*)btn {
    NSArray *array = @[Local(@"StatusDefault"),Local(@"OnLine"),Local(@"OffLine")];
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"OnlineStatus") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (cancelled) {
            _onlineStr = @"";
            [btn setTitle:array[0] forState:UIControlStateNormal];
        }else{
            if (buttonIndex == 1) {
                _onlineStr = @"Y";
            }else {
                _onlineStr = @"N";
            }
            [btn setTitle:array[buttonIndex] forState:UIControlStateNormal];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"OnLine"),Local(@"OffLine"),nil];
    [sheet showInView:self.view];
    sheet = nil;

}

//确定
- (void)sureAction:(EMButton*)btn {
    int fromAge = _startAge;
    int toAge = _endAge;
 
    //搜索
    MainViewController  *mainViewController = [[MainViewController alloc] init];
    mainViewController.isAdVanceSearch = YES;
    mainViewController.fromAge = [NSString stringWithFormat:@"%d",fromAge];
    mainViewController.endAge = [NSString stringWithFormat:@"%d",toAge];
    mainViewController.onLineStr = _onlineStr;
    mainViewController.identityStr = _identityStr;
    mainViewController.spkLangStr = _spkLangStr;
    mainViewController.cityStr = _cityStr;
    mainViewController.jobStr = _jobStr;
    mainViewController.chargeStr = _chargeStr;
    mainViewController.nickStr = _nickNameTextField.text;
    [self.navigationController pushViewController:mainViewController animated:YES];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"lowerValue"]||[keyPath isEqualToString:@"upperValue"]) {
        _startAge = _nmSlider.lowerValue * 81 + 18;
        _endAge = _nmSlider.upperValue * 81 +18;
        _ageLabel.text = [NSString stringWithFormat:@"%d%@~%d%@",_startAge,Local(@"Year"),_endAge,Local(@"Year")];
    }
}


- (void)dealloc {
    [_nmSlider removeObserver:self forKeyPath:@"upperValue" context:nil];
    [_nmSlider removeObserver:self forKeyPath:@"lowerValue" context:nil];

}

@end
