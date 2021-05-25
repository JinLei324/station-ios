//
//  StandViewController.m
//  LonelyStation
//
//  Created by zk on 16/5/22.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RoleDetailVC.h"
#import "UIUtil.h"

@interface RoleDetailVC (){
    EMButton *iKnowBtn;
}

@end

@implementation RoleDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setLeftBtn:nil];
    [self initViews];
    
    // Do any additional setup after loading the view.
}

-(void)initViews{
    EMButton *_forgetBtn = [self buttonWithName:Local(@"RoleDesp") andFrame:Rect(12, 52, 100*kScale, 44)];
    _forgetBtn.selected = YES;
    _forgetBtn.enabled = NO;
    _forgetBtn.titleLabel.font = ComFont(18*kScale);
    [self.view addSubview:_forgetBtn];
    EMView *_slideView = [[EMView alloc] initWithFrame:Rect(12, PositionY(_forgetBtn), 100, 3)];
    _slideView.backgroundColor = RGB(145,90,173);
    _slideView.center = Point(_forgetBtn.center.x, _slideView.center.y);
    [self.view addSubview:_slideView];
    
    CGFloat y = PositionY(_slideView);

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, y, kScreenW, kScreenH-22*2-38-y)];

    y = 28*kScale;
    
    EMLabel *firstLabel = [self labelWithFrame:Rect(30, y, kScreenW-30, 16) andSpace:6 andText:Local(@"RoleDefault")];
    firstLabel.textColor = RGB(145,90,173);
    firstLabel.font = ComFont(16*kScale);
    firstLabel.alpha = 0.9;
    [scrollView addSubview:firstLabel];
    y = PositionY(firstLabel) + 13*kScale;
    for (int i = 0; i<6; i++) {
        NSString *labelStr = [NSString stringWithFormat:@"RoleDesp%d",i];
        EMLabel *label = [self labelWithFrame:Rect(30, y, kScreenW-50, 35) andSpace:6 andText:Local(labelStr)];
        label.alpha = 0.9;
        [scrollView addSubview:label];
        y = PositionY(label)+16;
    }
    
    EMLabel *secondLabel = [self labelWithFrame:Rect(30, y, kScreenW-30, 16) andSpace:6 andText:Local(@"Voicer")];
    secondLabel.textColor = RGB(145,90,173);
    secondLabel.font = ComFont(16*kScale);
    secondLabel.alpha = 0.9;
    [scrollView addSubview:secondLabel];
    y = PositionY(secondLabel) + 13*kScale;
    for (int i = 0; i<5; i++) {
        NSString *labelStr = [NSString stringWithFormat:@"Voicer%d",i];
        EMLabel *label = [self labelWithFrame:Rect(30, y, kScreenW-50, 35) andSpace:6 andText:Local(labelStr)];
        label.alpha = 0.9;
        [scrollView addSubview:label];
        y = PositionY(label)+16;
    }
    
    EMLabel *thirdLabel = [self labelWithFrame:Rect(30, y, kScreenW-30, 16) andSpace:6 andText:Local(@"Secreter")];
    thirdLabel.textColor = RGB(145,90,173);
    thirdLabel.font = ComFont(16*kScale);
    thirdLabel.alpha = 0.9;
    [scrollView addSubview:thirdLabel];
    y = PositionY(thirdLabel) + 13*kScale;
    for (int i = 0; i<1; i++) {
        NSString *labelStr = [NSString stringWithFormat:@"Secreter%d",i];
        EMLabel *label = [self labelWithFrame:Rect(30, y, kScreenW-50, 35) andSpace:6 andText:Local(labelStr)];
        label.alpha = 0.9;
        [scrollView addSubview:label];
        y = PositionY(label)+16;
    }
    
    scrollView.contentSize = Size(0, y);
    [self.view addSubview:scrollView];
    if (!_backStr){
        _backStr = Local(@"IKnowAndBackUserInfo");
    }
    iKnowBtn = [UIUtil createPurpleBtnWithFrame:Rect(25, PositionY(scrollView)+27, kScreenW-50, 38) andTitle:_backStr andSelector:@selector(iKnowAction:)  andTarget:self];
    [self.view addSubview:iKnowBtn];
}

- (void)setBackStr:(NSString *)backStr {
    _backStr = backStr;
    [iKnowBtn setTitle:backStr forState:UIControlStateNormal];
}


-(void)iKnowAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(EMLabel*)labelWithFrame:(CGRect)rect andSpace:(CGFloat)space andText:(NSString*)str{
//    NSString * cLabelString = str;
    EMLabel * cLabel = [[EMLabel alloc]initWithFrame:rect];
    cLabel.numberOfLines = 0;
    cLabel.font = ComFont(14);
    cLabel.textColor = RGB(51,51,51);
    cLabel.text = str;
//    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:cLabelString];
//    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
//    [paragraphStyle1 setLineSpacing:space];
//    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [cLabelString length])];
//    [cLabel setAttributedText:attributedString1];
//    [cLabel sizeToFit];
    return cLabel;
}



-(EMButton*)buttonWithName:(NSString*)name andFrame:(CGRect)rect{
    EMButton *btn = [[EMButton alloc] initWithFrame:rect];
    btn.titStr = name;
    [btn setTitle:name forState:UIControlStateNormal];
    btn.titleLabel.font = ComFont(19);
    [btn setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    return btn;
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
