//
//  BuyInApp.h
//  LonelyStation
//
//  Created by zk on 2017/2/16.
//  Copyright © 2017年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAPHelper.h"
#import "IAPShare.h"
#import <StoreKit/StoreKit.h>
#import "NSString+Base64.h"
#import "ProgramObj.h"
#import "PayTypeObj.h"
#import "UserSettingViewModel.h"

@interface BuyInApp : NSObject

@property(nonatomic,copy)NSString *tradeCode;
@property(nonatomic,copy)NSString *receipt;
@property(nonatomic,strong)UserSettingViewModel *settingViewModel;

- (void)buyInApp:(PayTypeObj*)obj andProgramObj:(ProgramObj*)programObj andView:(UIView*)view andNavController:(UINavigationController*)nav;
@end
