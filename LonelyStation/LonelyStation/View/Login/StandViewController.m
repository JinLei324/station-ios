//
//  StandViewController.m
//  LonelyStation
//
//  Created by zk on 16/5/22.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "StandViewController.h"
#import "UIUtil.h"

@interface StandViewController (){
    EMButton *iKnowBtn;
}

@end

@implementation StandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.viewNaviBar setLeftBtn:nil];
    [self initViews];

    // Do any additional setup after loading the view.
}

-(void)initViews{
    
    EMButton *_forgetBtn = [self buttonWithName:Local(@"Standed") andFrame:Rect(12, 52, 86, 44)];
    _forgetBtn.selected = YES;
    _forgetBtn.enabled = NO;
    [self.view addSubview:_forgetBtn];
    EMView *_slideView = [[EMView alloc] initWithFrame:Rect(12, PositionY(_forgetBtn), 86, 3)];
    _slideView.backgroundColor = RGB(145,90,173);
    _slideView.center = Point(_forgetBtn.center.x, _slideView.center.y);
    [self.view addSubview:_slideView];
    
    EMLabel *firstLabel = [self labelWithFrame:Rect(15, PositionY(_slideView)+22, kScreenW-30, 35) andSpace:6 andText:Local(@"FirstLabel")];
    firstLabel.alpha = 0.9;
    [self.view addSubview:firstLabel];
    
    
    
    CGFloat y = PositionY(firstLabel)+16;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, y, kScreenW, kScreenH-27*2-38-y)];
    y = 0;
    for (int i = 0; i<10; i++) {
        EMLabel *pointLabel = [self labelWithFrame:Rect(15, y, 30, 35) andSpace:6 andText:[NSString stringWithFormat:@"%d.",i+1]];
        pointLabel.alpha = 0.9;
        [scrollView addSubview:pointLabel];
        NSString *labelStr = [NSString stringWithFormat:@"StandLabel%d",i+1];
        EMLabel *label = [self labelWithFrame:Rect(40, y, kScreenW-60, 35) andSpace:6 andText:Local(labelStr)];
        label.alpha = 0.9;
        [scrollView addSubview:label];
        y = PositionY(label)+16;
    }
    scrollView.contentSize = Size(0, y);
    [self.view addSubview:scrollView];
    if (!_backStr){
        _backStr = Local(@"IKnow");
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
    NSString * cLabelString = str;
    EMLabel * cLabel = [[EMLabel alloc]initWithFrame:rect];
    cLabel.numberOfLines = 0;
    cLabel.font = ComFont(14);
    cLabel.textColor = RGB(51,51,51);
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:cLabelString];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:space];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [cLabelString length])];
    [cLabel setAttributedText:attributedString1];
    [cLabel sizeToFit];
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
