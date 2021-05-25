//
//  EMViewController.h
//  emeNew
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNaviBarView.h"

@interface EMViewController : UIViewController{
    CustomNaviBarView *_viewNaviBar;
    BOOL isWhiteBar;
}


@property(nonatomic,strong)CustomNaviBarView *viewNaviBar;
@property(nonatomic,copy)NSString *titleStr;
@property(assign)BOOL isHiddenNavigationBar;


-(void)setUpBarWithColor:(NSString*)color;

-(void)back:(id)sender;

@end
