//
//  LoginViewModel.h
//  LonelyStation
//
//  Created by zk on 16/5/21.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetAccess.h"


@interface LoginViewModel : NSObject{
    NetAccess *_netAccess;
}


-(void)login:(NSString*)user andPwd:(NSString*)pwd andFlag:(NSString*)flag andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

-(void)forget:(NSString*)user andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

-(void)regist:(NSString*)email andPwd:(NSString*)pwd andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

-(void)registerNext:(NSString*)email andPwd:(NSString*)pwd andGender:(NSString*)gender andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

@end
