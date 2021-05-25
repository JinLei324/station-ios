//
//  UploadImgViewController.m
//  LonelyStation
//
//  Created by zk on 16/5/25.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UploadImgViewController.h"
#import "UIUtil.h"
#import "EMActionSheet.h"
#import "MBProgressHUD.h"
#import "UploadImgViewModel.h"
#import "ViewModelCommom.h"
#import "ChangePwdViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CameraSessionViewController.h"
#import "PECropViewController.h"
#import "EMAlertView.h"
#import "StandViewController.h"

@interface UploadImgViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,CameraSessionViewControllerDelegate,PECropViewControllerDelegate>{
    EMButton *_currentBtn;
    EMLabel *_currentLabel;
    UploadImgViewModel *_uploadImgViewModel;
    UIScrollView *scrollView;
    NSDictionary *statusDict;
}

@end

@implementation UploadImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    statusDict = @{@"1":Local(@"NoChecked"),@"2":Local(@"PendingChecking"),@"3":Local(@"RefuseCheck")};

    [self.viewNaviBar setTitle:Local(@"UploadImg") andColor:RGB(145,90,173)];
    [self initViews];
    _uploadImgViewModel = [[UploadImgViewModel alloc] init];
    //获取所有照片
    [self getAllPic];
    // Do any additional setup after loading the view.
}

- (void)getAllPic {
    [_uploadImgViewModel getAllImgWithBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                if (dict[@"info"][@"oneRow"]) {
                    NSDictionary *aDict = dict[@"info"][@"oneRow"];
                    if ([aDict isKindOfClass:[NSArray class]]) {
                        NSArray *array = (NSArray*)aDict;
                        for (int i = 0; i<array.count; i++) {
                            NSDictionary *childDict = array[i];
                            [[FileAccessData sharedInstance] setAObject:childDict[@"file"][@"text"] forEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],childDict[@"seq"][@"text"]]];
                            for (int i = 0; i < scrollView.subviews.count; i++) {
                                UIView *view = scrollView.subviews[i];
                                if ([view isKindOfClass:[EMButton class]]) {
                                    EMButton *btn = (EMButton*)view;
                                    if (btn.titStr.intValue > 0 && btn.titStr.intValue < 3) {
                                        NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],btn.titStr]] firstObject];
                                        [btn yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"cover_add"]];
                                    }else if (btn.titStr.intValue > 2 && btn.titStr.intValue < 6 && btn.titStr.intValue == [childDict[@"seq"][@"text"] intValue]){
                                        NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],btn.titStr]] firstObject];
                                        
                                        [btn yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"cover_add"]];
                                        
                                    }
                                }else if ([view isKindOfClass:[EMLabel class]]) {
                                    EMLabel *label = (EMLabel*)view;
                                    if ([label.labelId isEqualToString:childDict[@"seq"][@"text"]]) {
//                                        if ([statusDict[childDict[@"status"][@"text"]] intValue] != 1) {
                                            label.text = statusDict[childDict[@"status"][@"text"]];
//                                        }
                                    }
                                }
                            }
                            
                        }
                    }else if ([aDict isKindOfClass:[NSDictionary class]]) {
                        [[FileAccessData sharedInstance] setAObject:aDict[@"file"][@"text"] forEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],aDict[@"seq"][@"text"]]];
                        for (int i = 0; i < scrollView.subviews.count; i++) {
                            UIView *view = scrollView.subviews[i];
                            if ([view isKindOfClass:[EMButton class]]) {
                                EMButton *btn = (EMButton*)view;
                                if (btn.titStr.intValue > 0 && btn.titStr.intValue < 3) {
                                    NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],btn.titStr]] firstObject];
                                    [btn yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"cover_add"]];
                                }else if (btn.titStr.intValue > 2 && btn.titStr.intValue < 6){
                                    NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],btn.titStr]] firstObject];
                                    [btn yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"cover_add"]];

                                }
                            }else if ([view isKindOfClass:[EMLabel class]]) {
                                EMLabel *label = (EMLabel*)view;
                                if ([label.labelId isEqualToString:aDict[@"seq"][@"text"]]) {
//                                    if ([statusDict[aDict[@"status"][@"text"]] intValue] != 1) {
                                        label.text = statusDict[aDict[@"status"][@"text"]];
//                                    }
                                }
                            }
                        }
                    }
                   
                }
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}



-(void)initViews{
    
    //设置Label
    CGFloat x = 60 * kScreenW/375.f;
    EMLabel *desLabel = [[EMLabel alloc] initWithFrame:Rect(x, 50, kScreenW-2*x, 48)];
    desLabel.numberOfLines = 3;
    desLabel.text = Local(@"PublicImg");
    desLabel.font = ComFont(13);
    desLabel.textColor = RGB(51, 51, 51);
    [self.view addSubview:desLabel];
    
    scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, 98, kScreenW, kScreenH-98)];
    [self.view addSubview:scrollView];
    
    x = 80 * kScreenW/375.f;
    CGFloat y = 0;

    CGFloat btnwidth = 100 * kScreenW/375.f;
    CGFloat btnHight = 100 * kScreenW/375.f;
    CGFloat spareSpace = (kScreenW - btnwidth*2) - x*2;
    
    for (int i = 0; i<2; i++) {
        EMButton *pubBtn1 = [[EMButton alloc] initWithFrame:Rect(x, 0, btnwidth, btnHight)];
        pubBtn1.titStr = [NSString stringWithFormat:@"%d",i+1];
        NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],pubBtn1.titStr]] firstObject];
        [pubBtn1 yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"cover_add"]];
//        [pubBtn1 setImage:[UIImage imageNamed:@"uploadPicture"] forState:UIControlStateNormal];
//        [pubBtn1 setImage:[UIImage imageNamed:@"uploadPicture_d"] forState:UIControlStateHighlighted];
        
        pubBtn1.layer.cornerRadius = btnwidth/2.f;
        pubBtn1.layer.masksToBounds = YES;
        pubBtn1.tag = 500+i;

        [pubBtn1 addTarget:self action:@selector(uploadImg:) forControlEvents:UIControlEventTouchUpInside];
        
        EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(pubBtn1) + 5, btnwidth, 15)];
        label.labelId = [NSString stringWithFormat:@"%d",i+1];
        label.textColor = RGB(51, 51, 51);
//        label.text = statusDict[@"1"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = ComFont(13);
        label.tag = 1000+i;
        
        [scrollView addSubview:pubBtn1];
        [scrollView addSubview:label];
        x += spareSpace + btnwidth;
    }
    
    CGFloat privateSprate = 36;
    x = 49 * kScreenW/375.f;
    EMLabel *publicLabel = [[EMLabel alloc] initWithFrame:Rect(x, btnwidth+privateSprate, kScreenW-2*x, 48)];
    publicLabel.numberOfLines = 3;
    publicLabel.textColor = RGB(51, 51, 51);
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:Local(@"PrivateImgDes")];
    NSRange range = [Local(@"PrivateImgDes") rangeOfString:Local(@"PrivateImg")];
    [attrStr addAttribute:NSForegroundColorAttributeName
                value:RGB(242, 153, 255)  range:range];
    publicLabel.attributedText = attrStr;
//    publicLabel.text = Local(@"PrivateImgDes");
    publicLabel.font = ComFont(13);
    [scrollView addSubview:publicLabel];
    
    y = 191 * kScreenW/375.f;
    x = 44;
    btnwidth = 80 * kScreenW/375.f;
    spareSpace = ((kScreenW - btnwidth*3) - x*2)/2;
    for (int i = 0; i<3; i++) {
        EMButton *priBtn1 = [[EMButton alloc] initWithFrame:Rect(x, y, btnwidth, btnwidth)];
        priBtn1.titStr = [NSString stringWithFormat:@"%d",i+3];
        NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],priBtn1.titStr]] firstObject];
        [priBtn1 yy_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"cover_add"]];
        priBtn1.layer.cornerRadius = btnwidth/2.f;
        priBtn1.layer.masksToBounds = YES;
        [priBtn1 addTarget:self action:@selector(uploadImg:) forControlEvents:UIControlEventTouchUpInside];
        priBtn1.tag = 502+i;
        EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(priBtn1) + 5, btnwidth, 15)];
        label.labelId = [NSString stringWithFormat:@"%d",i+3];
        label.textColor = RGB(51, 51, 51);
//        label.text = statusDict[@"1"];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = ComFont(13);
        label.tag = 1002+i;
        [scrollView addSubview:priBtn1];
         [scrollView addSubview:label];
        x += spareSpace + btnwidth;
    }
    
//    privateSprate = 21 * kScreenW/375.f;
//    x = 33 * kScreenW/375.f;
//    y = 221 * kScreenW/375.f + btnwidth;
//    EMLabel *priLabel = [[EMLabel alloc] initWithFrame:Rect(x, y + privateSprate, kScreenW-2*x, 48)];
//    priLabel.numberOfLines = 3;
//    priLabel.textColor = RGB(51, 51, 51);
//    priLabel.textAlignment = NSTextAlignmentCenter;
//    NSMutableAttributedString *priAttrStr = [[NSMutableAttributedString alloc] initWithString:Local(@"PrivateImgDes")];
//    range = [Local(@"PrivateImgDes") rangeOfString:Local(@"PrivateImg")];
//    [priAttrStr addAttribute:NSForegroundColorAttributeName
//                    value:RGB(242, 153, 255)  range:range];
//    priLabel.attributedText = priAttrStr;
//    priLabel.font = ComFont(13);
//    [scrollView addSubview:priLabel];
    
    x = 26 * kScreenW/375.f;
    EMView *line = [[EMView alloc] initWithFrame:Rect(x, kScreenH -98-60*kScale,kScreenW - 2 * x, 1)];
    line.alpha = 0.7;
    line.backgroundColor = RGB(171, 171, 171);
    [scrollView addSubview:line];
    
    EMButton *lastLabel = [[EMButton alloc] initWithFrame:Rect(x, PositionY(line) + 11 * kScreenW/375.f, kScreenW-2*x, 48)];
//    lastLabel.numberOfLines = 3;
//    lastLabel.textColor = RGB(255, 255, 255);
//    lastLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *lastAttrStr = [[NSMutableAttributedString alloc] initWithString:Local(@"LastDes")];
    range = [Local(@"LastDes") rangeOfString:Local(@"SelfPic")];
    [lastAttrStr addAttribute:NSForegroundColorAttributeName
                        value:RGB(51,51,51)  range:NSMakeRange(0, Local(@"LastDes").length)];
    [lastAttrStr addAttribute:NSForegroundColorAttributeName
                       value:RGB(145,90,173)  range:range];
    [lastLabel setAttributedTitle:lastAttrStr forState:UIControlStateNormal];
//    lastLabel.attributedText = lastAttrStr;
    lastLabel.titleLabel.font = ComFont(13);
    [lastLabel addTarget:self action:@selector(toStand:) forControlEvents:UIControlEventTouchUpInside];
    [scrollView addSubview:lastLabel];

    scrollView.contentSize = Size(0, PositionY(lastLabel)+20);
}

- (void)toStand:(UITapGestureRecognizer*)gesture {
    StandViewController *stand = [[StandViewController alloc] init];
    [self.navigationController pushViewController:stand animated:YES];
    stand = nil;
}

//拍照完成后的回调，去编辑图片
- (void)didCaptureImageWithImage:(UIImage*)image {
    [self cropImage:image];
}

//调用编辑图片
- (void)cropImage:(UIImage*)image{
    PECropViewController *controller = [[PECropViewController alloc] init];
    controller.delegate = self;
    controller.image = image;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    CGFloat length = MIN(width, height);
    controller.imageCropRect = CGRectMake((width - length) / 2,
                                          (height - length) / 2,
                                          length,
                                          length);
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

    [self presentViewController:navigationController animated:YES completion:NULL];
    navigationController = nil;
    controller = nil;

}

- (void)uploadImg:(EMButton*)btn{
    _currentBtn = btn;
    _currentLabel = (EMLabel*)[scrollView viewWithTag:500+btn.tag];
    NSString *imgUrl = [[[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],btn.titStr]] firstObject];
    if (imgUrl == nil || [imgUrl isEqualToString:@""]) {
        //没有删除按钮
        EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"ChoosePhoto", @"Localization", nil) clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
            DLog(@"----%d",(int)buttonIndex);
            if (buttonIndex == 1) {
                CameraSessionViewController *controller = [[CameraSessionViewController alloc] init];
                controller.delegate = self;
                [self presentViewController:controller animated:YES completion:NULL];
                controller = nil;
            }else if(buttonIndex == 2){
                UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
                [ipc.navigationBar setBackgroundImage:[UIUtil imageWithColor:RGBA(0x98, 0x4a, 0xa6,1) andSize:Size(kScreenW, 64)] forBarMetrics:UIBarMetricsDefault];
                [ipc.navigationBar setTintColor:ColorFF];
                [ipc.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
                
                ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                ipc.delegate=self;
                [self presentViewController:ipc animated:YES completion:nil];
            }
        } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"Camra"),Local(@"ChooseFromAblue"),nil];
        [sheet showInView:self.view];
    } else {
        //有删除按钮
        NSString *deleteBtn = [_currentBtn.titStr intValue]>2?Local(@"DeletePrivate"):Local(@"DeletePublic");
        EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"ChoosePhoto", @"Localization", nil) clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
            DLog(@"----%d",(int)buttonIndex);
            if (buttonIndex == 1) {
                CameraSessionViewController *controller = [[CameraSessionViewController alloc] init];
                controller.delegate = self;
                [self presentViewController:controller animated:YES completion:NULL];
                controller = nil;
            }else if(buttonIndex == 2){
                UIImagePickerController *ipc=[[UIImagePickerController alloc] init];
                [ipc.navigationBar setBackgroundImage:[UIUtil imageWithColor:RGBA(0x98, 0x4a, 0xa6,1) andSize:Size(kScreenW, 64)] forBarMetrics:UIBarMetricsDefault];
                [ipc.navigationBar setTintColor:ColorFF];
                [ipc.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
                
                ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                ipc.delegate=self;
                [self presentViewController:ipc animated:YES completion:nil];
            }else if(buttonIndex == 3){
                AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"DeleteImg") message:Local(@"SureDeleteImg") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                    if (buttonIndex == 1) {
                        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                        hud.mode = MBProgressHUDModeIndeterminate;
                        if (!_uploadImgViewModel) {
                            _uploadImgViewModel = [[UploadImgViewModel alloc] init];
                        }
                        [_uploadImgViewModel deleteImgWithSeq:_currentBtn.titStr andBlock:^(NSDictionary *dict, BOOL ret) {
                            if (dict && ret) {
                                if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]){
                                    NSString *nomalImage = _currentBtn.titStr.intValue>2?@"cover_add":@"cover_add";
//                                     NSString *highlightedImage = _currentBtn.titStr.intValue>2?@"uploadPersonalPicture_d":@"uploadPicture_d";
                                    [_currentBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:@""] forState:UIControlStateNormal placeholder:[UIImage imageNamed:nomalImage]];
//                                    [_currentBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:@""] forState:UIControlStateHighlighted placeholder:[UIImage imageNamed:highlightedImage]];
                                    [[FileAccessData sharedInstance] setAObject:@"" forEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],_currentBtn.titStr]];
                                    [self.view makeToast:Local(@"DeleteSuccess")  duration:ERRORTime position:[CSToastManager defaultPosition]];
                                    if (_currentLabel) {
                                        _currentLabel.text = @"";
                                    }
                                }else {
                                    [self.view makeToast:[[dict objectForKey:@"msg"] objectForKey:@"text"]  duration:ERRORTime position:[CSToastManager defaultPosition]];
                                }
                            }else {
                                [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];

                            }
                            [hud hide:YES];
                        }];
                    }
                } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
                [alert show];
              
            }
        } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:Local(@"Camra"),Local(@"ChooseFromAblue"),deleteBtn,nil];
        [sheet showInView:self.view];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (navigationController.viewControllers.count == 1)
    {
        UIPageViewController *controller = (UIPageViewController*)navigationController.viewControllers[0];
        DLog(@"%@",controller.view.subviews);
    }
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *) info{
    UIImage *img=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:NO completion:nil];
    [self cropImage:img];
}

- (void)uploadImgToService:(UIImage*)img {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText =  Local(@"UploadIng");
    NSData * data = UIImageJPEGRepresentation(img,0.7);
    if (!_uploadImgViewModel) {
        _uploadImgViewModel = [[UploadImgViewModel alloc] init];
    }
    NSString *property = [_currentBtn.titStr intValue]>2?@"private":@"public";
    [_uploadImgViewModel updateImg:data andProperty:property andSeq:_currentBtn.titStr andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                UIImage *aimg = [UIUtil circleImage:img withParam:2];
                [_currentBtn setBackgroundImage:aimg forState:UIControlStateNormal];
                [[FileAccessData sharedInstance] setAObject:[[dict objectForKey:@"img"] objectForKey:@"text"] forEMKey:[NSString stringWithFormat:@"%@%@",[ViewModelCommom getCurrentEmail],_currentBtn.titStr]];
                [self.view makeToast:Local(@"UploadSuccess")  duration:ERRORTime position:[CSToastManager defaultPosition]];
                _currentLabel.text = statusDict[@"1"];

            }else{
                [self.view makeToast:[[dict objectForKey:@"msg"] objectForKey:@"text"]  duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else{
            [self.view makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        [hud hide:YES];
    }];
}


#pragma mark - PECropViewControllerDelegate methods

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage transform:(CGAffineTransform)transform cropRect:(CGRect)cropRect
{
    [self uploadImgToService:croppedImage];
    [controller dismissViewControllerAnimated:YES completion:NULL];
  
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
