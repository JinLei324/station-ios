//
//  LoginStatusObj.h
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMObject.h"

@interface LoginStatusObj : EMObject

@property(nonatomic,assign)BOOL isLogined;
@property(nonatomic,assign)BOOL shouldGetUserMsg;
@property(nonatomic,copy)NSString *gender;

@end
