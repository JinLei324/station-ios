//
//  PersonInfoViewController.m
//  LonelyStation
//
//  Created by zk on 16/5/23.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PersonInfoViewController.h"
#import "EMButton.h"
#import "EMLabel.h"
#import "EMView.h"
#import "UIUtil.h"
#import "ZHPickView.h"
#import "UploadImgViewController.h"
#import "EMUtil.h"
#import "PersonInfoViewModel.h"
#import "ViewModelCommom.h"
#import "MainTabBarController.h"
#import "LeftSortsViewController.h"
#import "EMActionSheet.h"
#import "MainViewVM.h"
#import "LonelySpkLang.h"
#import "TelValidateVC.h"
#import "LoginStatusObj.h"

@interface PersonInfoViewController ()<ZHPickViewDelegate>{
    NSMutableDictionary *_textFieldDict;
    NSArray *_labelArray;
    EMButton *selectedBtn;
    ZHPickView *datePicker;
    PersonInfoViewModel *personInfoViewModel;
    NSDictionary *langdict;
    NSMutableDictionary *dataDict;
    EMButton *rightBtn;
    EMButton *uploadBtn;
    MainViewVM *_mainViewVM;
    NSMutableArray *_languageArray;
    NSMutableArray *_countryArray;
    NSMutableArray *_cityArray;
    
    LonelyCountry *_currentCountry;
}

@end

@implementation PersonInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mainViewVM = [[MainViewVM alloc] init];
    [self initalData];
    [self initViews];
    [self.viewNaviBar setTitle:Local(@"PersonalInfo") andColor:RGB(145,90,173)];
    [self.viewNaviBar setLeftBtn:nil];
    // Do any additional setup after loading the view.
}

//获取语言和显示
- (void)getLanguageListAndShow:(EMTextField*)textfield {
    [UIUtil showHUD:self.view];
    [personInfoViewModel getLangWithBlock:^(NSArray *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _languageArray = nil;
            _languageArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showLanguageSheet:textfield];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示语言列表
- (void)showLanguageSheet:(EMTextField*)textField {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Lang") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelySpkLang *langSpk = _languageArray[buttonIndex-1];
            textField.text = langSpk.langName;
            [dataDict setObject:langSpk.langId forKey:Local(@"Lang")];
        }else {
            textField.text = @"";
            [dataDict setObject:@"" forKey:Local(@"Lang")];
        }
        
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _languageArray.count; i++) {
        LonelySpkLang *spkLang = _languageArray[i];
        [sheet addButtonWithTitle:spkLang.langName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}



//语言
- (void)laguageAction:(EMTextField*)textfield {
    if (!_languageArray) {
        [self getLanguageListAndShow:textfield];
    }else {
        if (_languageArray.count == 0) {
            [self getLanguageListAndShow:textfield];
        }else {
            [self showLanguageSheet:textfield];
        }
    }
}



- (void)getCountryListAndShow:(EMTextField*)texfield {
    [UIUtil showHUD:self.view];
    [_mainViewVM getCountryListWithBlock:^(NSArray<LonelyCountry *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _countryArray = nil;
            _countryArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showCountrySheet:texfield];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


//显示国家列表
- (void)showCountrySheet:(EMTextField*)texfield {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Country") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyCountry *country = _countryArray[buttonIndex-1];
            _currentCountry = country;
            texfield.text = country.countryName;
            [dataDict setObject:country.countryId forKey:Local(@"Country")];
        }else {
            _currentCountry = nil;
            [dataDict setObject:@"" forKey:Local(@"Country")];
        }
        
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _countryArray.count; i++) {
        LonelyCountry *country = _countryArray[i];
        [sheet addButtonWithTitle:country.countryName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//国家
- (void)countryAction:(EMTextField*)texfield {
    if (!_countryArray) {
        [self getCountryListAndShow:texfield];
    }else {
        if (_countryArray.count == 0) {
            [self getCountryListAndShow:texfield];
        }else {
            [self showCountrySheet:texfield];
        }
    }
}



//城市
- (void)cityAction:(EMTextField*)texfield {
    if (!_currentCountry || [_currentCountry.countryId intValue] <= 0) {
        [self.view makeToast:Local(@"PlsSelectCountry") duration:1 position:[CSToastManager defaultPosition]];
    }else {
        [self getCityAndShow:texfield];
    }
}

//获取城市和显示
- (void)getCityAndShow:(EMTextField*)texfield{
    [UIUtil showHUD:self.view];
    [_mainViewVM getCityListByCountryId:_currentCountry.countryId andBlock:^(NSArray<LonelyCity *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _cityArray = nil;
            _cityArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showCitySheet:texfield];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示城市列表
- (void)showCitySheet:(EMTextField*)texfield {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"City") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyCity *city = _cityArray[buttonIndex-1];
            texfield.text = city.cityName;
            [dataDict setObject:city.cityId forKey:Local(@"City")];
        }else {
            texfield.text = @"";
            [dataDict setObject:@"" forKey:Local(@"City")];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _cityArray.count; i++) {
        LonelyCity *city = _cityArray[i];
        [sheet addButtonWithTitle:city.cityName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}



- (void)initalData {
    _textFieldDict = [NSMutableDictionary dictionary];
    _labelArray = @[Local(@"NickName"),Local(@"Birthday"),Local(@"Sex"),Local(@"Lang"),Local(@"Country"),Local(@"City")];
    dataDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < _labelArray.count; i++) {
        [dataDict setObject:@"" forKey:_labelArray[i]];
        [dataDict addObserver:self forKeyPath:_labelArray[i] options:NSKeyValueObservingOptionNew context:nil];
    }
    personInfoViewModel = [[PersonInfoViewModel alloc] init];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    BOOL rightCanClick = YES;
    for (int i = 0; i < _labelArray.count;i++) {
        if ([dataDict[_labelArray[i]] isEqualToString:@""]) {
            rightCanClick = NO;
            break;
        }
    }
    if (rightCanClick) {
        [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,1) forState:UIControlStateNormal];
        [rightBtn setEnabled:YES];
    }else {
        [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,0.5) forState:UIControlStateNormal];
        [rightBtn setEnabled:NO];
    }
}

- (void)completeAction:(EMButton*)btn {
    BOOL haveImg = NO;
    for (int i = 0; i<2; i++) {
         NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%d",[ViewModelCommom getCurrentEmail],i+1]] firstObject];
        if (imgUrl && ![imgUrl isEqualToString:@""]) {
            haveImg = YES;
            break;\
        }
    }
    if (!haveImg) {
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"YouForgetUploadImg") message:Local(@"YouForgetUploadImgInfo") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if(buttonIndex == 1){
                [self uploadAction:nil];
            }else {
                [self upLoadInfo];
            }
        } cancelButtonTitle:Local(@"NextTime") otherButtonTitles:Local(@"UploadNow"), nil];
        [alert show];
    } else {
        [self upLoadInfo];
    }
    
}


- (void)upLoadInfo {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [personInfoViewModel updateMoreInfo:dataDict[_labelArray[0]]
                            andBirthDay:dataDict[_labelArray[1]]
                              andGender:    dataDict[_labelArray[2]]
                                andLang:    dataDict[_labelArray[3]]
                             andCountry:    dataDict[_labelArray[4]]
                                andCity:    dataDict[_labelArray[5]]
                               andBlock:^(NSDictionary *dict, BOOL ret) {
                                   if (dict && ret) {
                                       if ([dict[@"code"][@"text"] intValue] == 1) {
                                           user.nickName = dataDict[_labelArray[0]];
                                           user.birthday =  dataDict[_labelArray[1]];
                                           user.gender =  dataDict[_labelArray[2]];
                                           user.currentLang =  dataDict[_labelArray[3]];
                                           user.country = dataDict[_labelArray[4]];
                                           user.city = dataDict[_labelArray[5]];
                                           user.imtoken = dict[@"data"][@"imtoken"][@"text"];
                                           [ViewModelCommom saveUser:user];
                                           LonelyUser *aUser = [ViewModelCommom getCuttentUser];
                                           DLog(@"%@",aUser);
                                           [self.view makeToast:Local(@"UpLoadInfoSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                           NSString *giftQualifiedStr =NOTNULLObj(dict[@"data"][@"GiftQualified"][@"text"]);
                                           if ([giftQualifiedStr isEqualToString:@"Y"]) {
                                               //进入手机认证
                                               [self jumpToTelValidate];
                                           }else {
                                               [self jumpToMain];
                                           }
                                       }else{
                                           [self.view makeToast:[[dict objectForKey:@"msg"] objectForKey:@"text"]  duration:ERRORTime position:[CSToastManager defaultPosition]];
                                       }
                                   }else{
                                       [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                   }
                               }];
}

- (void)jumpToTelValidate {
    TelValidateVC *telValidateVC = [[TelValidateVC alloc] init];
    [self.navigationController pushViewController:telValidateVC animated:YES];
}


- (void)jumpToMain {
    MainTabBarController *mainTab = [[MainTabBarController alloc] init];
    mainTab.isHiddenNavigationBar = YES;
    mainTab.shouldLogin3rd = YES;
    
    LoginStatusObj *loginedStatus = [[LoginStatusObj alloc] init];
    loginedStatus.isLogined = YES;
    loginedStatus.shouldGetUserMsg = YES;
    [[FileAccessData sharedInstance] setAObject:loginedStatus forEMKey:@"LoginStatus"];
    
    LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
    LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:mainTab];
    mainTab.slideViewCtl = leftSlideVC;
    [self.navigationController pushViewController:leftSlideVC animated:YES];
    mainTab = nil;
}

-(void)initViews{
    rightBtn = [[EMButton alloc] initWithFrame:Rect(0, 22, 70, 30)];
    [rightBtn setTitle:Local(@"Complate") forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton"] forState:UIControlStateNormal];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton_d"] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:ComFont(16)];

    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,0.5) forState:UIControlStateNormal];
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,1) forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:rightBtn];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    [self.view addSubview:scrollView];
    
    uploadBtn = [[EMButton alloc] initWithFrame:Rect((kScreenW-114)/2, 110-64, 114, 114)];
    uploadBtn.layer.cornerRadius = 114/2;
    uploadBtn.layer.masksToBounds = YES;
    [uploadBtn addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:uploadBtn];
    
    EMLabel *desLabel = [[EMLabel alloc] initWithFrame:Rect((kScreenW-220)/2, PositionY(uploadBtn)+15, 220, 14)];
    desLabel.textColor = RGB(255, 252, 0);
    desLabel.font = ComFont(14);
    desLabel.text = Local(@"UploadImageCanUseMore");
    [scrollView addSubview:desLabel];
    
    EMView *line = [[EMView alloc] initWithFrame:Rect((kScreenW-325*kScreenW/375)/2, PositionY(desLabel)+18, 325*kScreenW/375, 2)];
    line.backgroundColor = RGB(0xff, 0xff, 0xff);
    line.alpha = 0.7;
    [scrollView addSubview:line];
    CGFloat y = 0;
    CGFloat x = 53;
    CGFloat xspace = 23;
    if (Is320) {
        x = 22;
        xspace = 13;
    }
    CGFloat sexLabelx = 0;
    for (int i = 0; i<_labelArray.count; i++) {
        EMLabel *aLabel = [self labelWithText:_labelArray[i] andFont:ComFont(13) andColor:RGB(0xff, 0xff, 0xff) andFrame:Rect(x, PositionY(line)+53+55*i, 30, 13) andAlpha:0.6];
        [scrollView addSubview:aLabel];
        if (i == 2) {
            NSArray *sexArray = @[Local(@"Boy"),Local(@"Girl")];
            for (int j = 0; j<sexArray.count; j++) {
                EMButton *boyButton = [[EMButton alloc] initWithFrame:Rect(PositionX(aLabel)+xspace+71*j, PositionY(line)+46+55*i, 27, 27)];
                [boyButton setImage:[UIImage imageNamed:@"singlenoButton"] forState:UIControlStateNormal];
                [boyButton setImage:[UIImage imageNamed:@"singleyesButton"] forState:UIControlStateSelected];
                boyButton.titStr = [sexArray[j] isEqualToString:Local(@"Boy")]?@"M":@"F";
                if (j == 0) {
                    boyButton.selected = YES;
                    selectedBtn = boyButton;
                    [dataDict setObject:boyButton.titStr forKey:Local(@"Sex")];
                }
                [boyButton addTarget:self action:@selector(sexAction:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:boyButton];
                EMLabel *boyLabel = [self labelWithText:sexArray[j] andFont:ComFont(13) andColor:RGB(0xff, 0xff, 0xff) andFrame:Rect(PositionX(boyButton)+8, PositionY(line)+53+55*i, 30, 13) andAlpha:0.6];
                [scrollView addSubview:boyLabel];
                sexLabelx = PositionX(boyLabel);
            }
            EMLabel *desLabel = [self labelWithText:Local(Local(@"CannotChange")) andFont:ComFont(13) andColor:RGB(235,173,255) andFrame:Rect(sexLabelx+7, PositionY(line)+53+55*i, 120, 13) andAlpha:0.6];
            [scrollView addSubview:desLabel];
        }else{
             EMTextField *aTextField = [self textFieldWithPlaceHolder:_labelArray[i] andName:_labelArray[i] andFrame:Rect(PositionX(aLabel)+xspace, PositionY(line)+43+(25+30)*i, kScreenW-54-x*2, 30) andScrollView:scrollView];
            [_textFieldDict setObject:aTextField forKey:_labelArray[i]];
            y = PositionY(aTextField);
        }
    }
    scrollView.contentSize = Size(0, y+66);
    [self setupTextFieldInputView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],@"1"]] firstObject];
    [uploadBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"uploadPicture"]];
    [uploadBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateHighlighted placeholder:[UIImage imageNamed:@"uploadPicture_d"]];
}

-(void)textChangeAction:(EMTextField*)textField {
    [dataDict setObject:textField.text forKey:Local(@"NickName")];
}


- (void)setupTextFieldInputView {
    EMTextField *nickNameField = [_textFieldDict objectForKey:Local(@"NickName")];
    [nickNameField addTarget:self action:@selector(textChangeAction:) forControlEvents:UIControlEventEditingChanged];
    
    EMTextField *birthTextField = [_textFieldDict objectForKey:Local(@"Birthday")];
    NSDate *date=[NSDate date];
    datePicker = [[ZHPickView alloc] initDatePickWithDate:date datePickerMode:UIDatePickerModeDate isHaveNavControler:YES];
    if (![birthTextField.text isEqualToString:@""]) {
         date = [EMUtil parseDateFromString:birthTextField.text andFormate:@"YYYY/MM/dd"];
    }
    datePicker.defaultDatePickerDate = date;
    datePicker.delegate = self;
    [birthTextField setEnabled:NO];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFiledTextAction:)];
    [birthTextField.superview addGestureRecognizer:tapGesture];
    
    EMTextField *countryTextField = [_textFieldDict objectForKey:Local(@"Country")];
    [countryTextField setEnabled:NO];
    
    EMTextField *langTextField = [_textFieldDict objectForKey:Local(@"Lang")];
    [langTextField setEnabled:NO];
    
    EMTextField *cityTextField = [_textFieldDict objectForKey:Local(@"City")];
    [cityTextField setEnabled:NO];
}

- (void)textFiledTextAction:(UITapGestureRecognizer*)tapGesture {
    [self.view endEditing:YES];
    EMTextField *birthTextField = [_textFieldDict objectForKey:Local(@"Birthday")];
    EMTextField *countryTextField = [_textFieldDict objectForKey:Local(@"Country")];
    EMTextField *langTextField = [_textFieldDict objectForKey:Local(@"Lang")];
    EMTextField *cityTextField = [_textFieldDict objectForKey:Local(@"City")];
    
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        if (CGRectContainsPoint(birthTextField.frame, point))
        {
            [datePicker show];
        }else if (CGRectContainsPoint(countryTextField.frame, point))
        {
            [self countryAction:countryTextField];
        }else if (CGRectContainsPoint(langTextField.frame, point))
        {
            [self laguageAction:langTextField];
        }else if (CGRectContainsPoint(cityTextField.frame, point))
        {
            [self cityAction:cityTextField];
        }
    }
}

- (void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString {
    if (pickView == datePicker) {
        [datePicker remove];
        EMTextField *birthTextField = [_textFieldDict objectForKey:Local(@"Birthday")];
        NSString *birthday = [EMUtil getDateStringWithDate:[EMUtil parseDateFromString:resultString andFormate:@"YYYY-MM-dd HH:mm:ss"] DateFormat:@"YYYY/MM/dd"];
        birthTextField.text = birthday;
        [dataDict setObject:birthday forKey:Local(@"Birthday")];
    }
}

-(void)toobarDonBtnCancel{
    [datePicker remove];
}



- (void)uploadAction:(EMButton*)btn{
    UploadImgViewController *uploadViewController = [[UploadImgViewController alloc] init];
    [self.navigationController pushViewController:uploadViewController animated:YES];
    uploadViewController = nil;
}

- (void)sexAction:(EMButton*)btn {
    if (selectedBtn != btn) {
        if (!selectedBtn) {
            selectedBtn = btn;
        }else{
            selectedBtn.selected = NO;
        }
        btn.selected = !btn.selected;
        selectedBtn = btn;
        [dataDict setObject:selectedBtn.titStr forKey:Local(@"Sex")];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (EMLabel*)labelWithText:(NSString*)text andFont:(UIFont*)font andColor:(UIColor*)color andFrame:(CGRect)rect andAlpha:(CGFloat)alpha{
    EMLabel *nickLabel = [[EMLabel alloc] initWithFrame:rect];
    nickLabel.font = font;
    nickLabel.text = text;
    nickLabel.textColor = color;
    nickLabel.alpha = alpha;
    return nickLabel;
}


-(EMTextField*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect andScrollView:(UIScrollView*)scrollView{
    EMImageView *filedBack = [[EMImageView alloc] initWithFrame:rect];
    filedBack.alpha = 0.15;
    filedBack.backgroundColor = RGB(0xff, 0xff, 0xff);
    filedBack.layer.cornerRadius = rect.size.height/2;
    filedBack.layer.masksToBounds = YES;
    rect.origin.x = rect.origin.x + 20;
    rect.size.width = rect.size.width-40;
    EMTextField *field = [[EMTextField alloc] initWithFrame:rect];
    field.placeholder = placeHolder;
    field.font = ComFont(13);
    [field setTintColor:RGB(0xff,0xff,0xff)];
    field.textColor = RGB(0xff,0xff,0xff);
//    [field setValue:RGBA(0xff, 0xff, 0xff,0.6) forKeyPath:@"_placeholderLabel.textColor"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(field, ivar);

    placeholderLabel.textColor = RGBA(0xff, 0xff, 0xff,0.6);
    field.titStr = name;
    [scrollView addSubview:filedBack];
    [scrollView addSubview:field];
    return field;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
