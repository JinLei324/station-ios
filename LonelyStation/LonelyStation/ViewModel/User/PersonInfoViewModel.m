//
//  PersonInfoViewModel.m
//  LonelyStation
//
//  Created by zk on 16/5/26.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PersonInfoViewModel.h"
#import "LonelyCountry.h"
#import "LonelyCity.h"
#import "LonelySpkLang.h"
#import "ViewModelCommom.h"

@implementation PersonInfoViewModel

-(void)getCityWithCountryId:(NSString*)countryId andBlock:(void(^)(NSArray *array,BOOL ret))block{
    NSArray *array = [ViewModelCommom getCityArrayWithCountryId:countryId];
    //判断要不要重新加载 如果是打开软件后的第一次请求，都需要重新加载
    NSString *shouldReload = [[FileAccessData sharedInstance] objectForMemKey:[NSString stringWithFormat:@"shouldReload%@%@",countryId,GETCountryCode]];
    if (array && shouldReload && [shouldReload isEqualToString:@"0"]) {
        NSMutableArray *cityNameArr = [NSMutableArray array];
        for (LonelyCity *city in array) {
            [cityNameArr addObject:city.cityName];
        }
        block(cityNameArr,YES);
    }else{
        if (!_netAccess) {
            _netAccess = [[NetAccess alloc] init];
        }
        [_netAccess getCityListWithCountry:countryId andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
            if (dict && ret && [dict isKindOfClass:[NSArray class]]) {
                DLog(@"dict==%@",dict);
                NSArray *arr = (NSArray*)dict;
                NSMutableArray *cityArr = [NSMutableArray array];
                NSMutableArray *cityNameArr = [NSMutableArray array];
                for (NSDictionary *cityDic in arr) {
                    LonelyCity *city = [[LonelyCity alloc] initWithDict:cityDic];
                    [cityArr addObject:city];
                    [cityNameArr addObject:city.cityName];
                }
                if (cityArr.count > 0) {
                    [[FileAccessData sharedInstance] setAObject:cityArr forEMKey:[NSString stringWithFormat:@"%@city%@",countryId,GETCountryCode]];
                    [[FileAccessData sharedInstance] setMemObject:@"0" forKey:[NSString stringWithFormat:@"shouldReload%@%@",countryId,GETCountryCode]];
                }
                block(cityNameArr,ret);
            }else{
                block(nil,NO);
            }
            
        }];
    }
}


-(void)getLangWithBlock:(void(^)(NSArray *langArray,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess getspkListWithBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret && [[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
            NSArray *array = [[dict objectForKey:@"data"] objectForKey:@"oneRow"];
            NSMutableArray *langArr = [NSMutableArray array];
            for (int i = 0; i < array.count; i++) {
                LonelySpkLang *lang = [[LonelySpkLang alloc] initWithDict:[array objectAtIndex:i]];
                [langArr addObject:lang];
            }
            block(langArr,ret);
        }else{
            block(nil,ret);
        }
    }];
}


-(void)getCountryWithBlock:(void(^)(NSArray *array,BOOL ret))block{
    NSArray *array = [ViewModelCommom getCountryArray];
    //判断要不要重新加载 如果是打开软件后的第一次请求，都需要重新加载
    NSString *shouldReload = [[FileAccessData sharedInstance] objectForMemKey:@"shouldReloadCountry"];
    if (array && shouldReload && [shouldReload isEqualToString:@"0"]) {
        NSMutableArray *countryNameArr = [NSMutableArray array];
        
        for (LonelyCountry *country in array) {
            [countryNameArr addObject:country.countryName];
        }
        block(countryNameArr,YES);
    }else{
        if (!_netAccess) {
            _netAccess = [[NetAccess alloc] init];
        }
        [_netAccess getCountryListWithblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
            if (dict && ret && [dict isKindOfClass:[NSArray class]]) {
                NSArray *arr = (NSArray*)dict;
                NSMutableArray *countryArr = [NSMutableArray array];
                NSMutableArray *countryNameArr = [NSMutableArray array];
                for (NSDictionary *countryDic in arr) {
                    LonelyCountry *country = [[LonelyCountry alloc] initWithDict:countryDic];
                    [countryArr addObject:country];
                    [countryNameArr addObject:country.countryName];
                }
                if (countryArr.count > 0) {
                    [[FileAccessData sharedInstance] setAObject:countryArr forEMKey:@"country"];
                    
                    [[FileAccessData sharedInstance] setMemObject:@"0" forKey:@"shouldReloadCountry"];
                }
                block(countryNameArr,ret);
            }else{
                block(nil,NO);
            }
            
        }];
    }
}

- (void)updateMoreInfo:(NSString*)nickName andBirthDay:(NSString*)birth andGender:(NSString*)gender andLang:(NSString*)lang andCountry:(NSString*)country andCity:(NSString*)city andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    
    [_netAccess updateInfo:nickName andUserId:[ViewModelCommom getCuttentUserId] andUser:[ViewModelCommom getCurrentEmail] andBirthday:birth andGender:gender andLang:lang andCountry:country andCity:city andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

@end
