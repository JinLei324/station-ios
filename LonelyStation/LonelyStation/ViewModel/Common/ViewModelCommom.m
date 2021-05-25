//
//  ViewModelCommom.m
//  LonelyStation
//
//  Created by zk on 16/5/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ViewModelCommom.h"
#import "LonelyCountry.h"
#import "LonelyCity.h"
#import "LonelyUser.h"
#import "LonelySpkLang.h"

@implementation ViewModelCommom

+ (NSString*)getCountryIdWithName:(NSString*)name {
    NSArray *array = [[FileAccessData sharedInstance] objectForEMKey:@"country"];
    for (NSDictionary *dict in array) {
        LonelyCountry *country = [LonelyCountry yy_modelWithDictionary:dict];
        if ([country.countryName isEqualToString:name]) {
            return country.countryId;
        }
    }
    return @"";
}

+ (NSString*)getLangIdWithName:(NSString*)name {
    NSArray *array = [[FileAccessData sharedInstance] objectForEMKey:@"lang"];
    for (NSDictionary *dict in array) {
        LonelySpkLang *country = [LonelySpkLang yy_modelWithDictionary:dict];
        if ([country.langName isEqualToString:name]) {
            return country.langId;
        }
    }
    return @"";
}


+ (NSString*)getCityIdWithName:(NSString*)name andCountryId:(NSString*)countryId {
    NSArray *array = [[self class] getCityArrayWithCountryId:countryId];
    for (LonelyCity *city in array) {
        if ([city.cityName isEqualToString:name]) {
            return city.cityId;
        }
    }
    return @"";
}

+ (NSArray*)getLangArray {
    NSArray *array = [[FileAccessData sharedInstance] objectForEMKey:@"lang"];
    NSMutableArray *langArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        LonelySpkLang *lang = [LonelySpkLang yy_modelWithDictionary:dict];
        [langArray addObject:lang];
    }
    return langArray;
}

+ (NSArray*)getCountryArray {
    NSArray *array = [[FileAccessData sharedInstance] objectForEMKey:@"country"];
    NSMutableArray *countryArray = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        LonelyCountry *country = [LonelyCountry yy_modelWithDictionary:dict];
        [countryArray addObject:country];
    }
    return countryArray;
}


+ (NSArray*)getCityArrayWithCountryId:(NSString*)countryId {
    NSArray *array = [[FileAccessData sharedInstance] objectForEMKey:[NSString stringWithFormat:@"%@city%@",countryId,GETCountryCode]];
    if (array) {
        NSMutableArray *cityArray = [NSMutableArray array];
        for (NSDictionary *dict in array) {
            LonelyCity *city = [LonelyCity yy_modelWithDictionary:dict];
            [cityArray addObject:city];
        }
        return cityArray;
    }else {
        return nil;
    }
}


+ (void)setCurrentEmail:(NSString*)email {
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:@"currentUserEmail"];

}

+ (NSString*)getCurrentEmail {
    return  [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUserEmail"];
}

+ (NSString*)getCuttentUserId {
    NSString *email = [[self class] getCurrentEmail];
    LonelyUser *user = [LonelyUser yy_modelWithDictionary:[[FileAccessData sharedInstance] objectForEMKey:email]];
    return user.userID;
}

+ (NSString*)getCurrentHeadImgPath {
    NSString *email = [[self class] getCurrentEmail];
    LonelyUser *user = [LonelyUser yy_modelWithDictionary:[[FileAccessData sharedInstance] objectForEMKey:email]];
    return user.currentHeadImage;
}

+ (LonelyUser*)getCuttentUser {
    NSString *email = [[self class] getCurrentEmail];
    LonelyUser *user = [LonelyUser yy_modelWithDictionary:[[FileAccessData sharedInstance] objectForEMKey:email]];
    return user;
}

+ (void)saveUser:(LonelyUser*)user {
    [[FileAccessData sharedInstance] setAObject:user forEMKey:[[self class] getCurrentEmail]];
}


@end
