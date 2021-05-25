//
//  ChatListViewController.h
//  RongCloudDemo
//
//  Created by 杜立召 on 15/4/18.
//  Copyright (c) 2015年 dlz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
#import "CustomNaviBarView.h"
#import "MainTabBarController.h"

@interface ChatListViewController : RCConversationListViewController {
    CustomNaviBarView *_viewNaviBar;
}

@property(nonatomic,weak)MainTabBarController *tabViewController;

@end
