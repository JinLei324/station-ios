//
//  ChatViewController.h
//  RongCloudDemo
//
//  Created by zk on 2016/10/21.
//  Copyright © 2016年 dlz. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "LonelyStationUser.h"

@interface ChatViewController : RCConversationViewController

@property(nonatomic,strong)LonelyStationUser *lonelyUser;

@end
