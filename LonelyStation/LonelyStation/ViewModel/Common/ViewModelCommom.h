//
//  ViewModelCommom.h
//  LonelyStation
//
//  Created by zk on 16/5/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "LonelyUser.h"

@interface ViewModelCommom : EMObject

+ (NSString*)getCountryIdWithName:(NSString*)name;

+ (NSArray*)getCountryArray;

+ (NSArray*)getLangArray;

+ (NSString*)getLangIdWithName:(NSString*)name;

+ (NSArray*)getCityArrayWithCountryId:(NSString*)countryId;

+ (NSString*)getCityIdWithName:(NSString*)name andCountryId:(NSString*)countryId ;

+ (void)setCurrentEmail:(NSString*)email;

+ (NSString*)getCurrentEmail;

+ (NSString*)getCuttentUserId;

+ (NSString*)getCurrentHeadImgPath;

+ (LonelyUser*)getCuttentUser;

+ (void)saveUser:(LonelyUser*)user;

@end
