//
//  PersonInfoViewModel.h
//  LonelyStation
//
//  Created by zk on 16/5/26.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetAccess.h"


@interface PersonInfoViewModel : NSObject{
    NetAccess *_netAccess;
}


- (void)getCountryWithBlock:(void(^)(NSArray *array,BOOL ret))block;


-(void)getLangWithBlock:(void(^)(NSArray *langArr,BOOL ret))block;


- (void)getCityWithCountryId:(NSString*)countryId andBlock:(void(^)(NSArray *array,BOOL ret))block;

- (void)updateMoreInfo:(NSString*)nickName andBirthDay:(NSString*)birth andGender:(NSString*)gender andLang:(NSString*)lang andCountry:(NSString*)country andCity:(NSString*)city andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

@end
