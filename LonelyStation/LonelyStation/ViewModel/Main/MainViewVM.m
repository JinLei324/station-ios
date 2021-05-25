//
//  MainViewVM.m
//  LonelyStation
//
//  Created by zk on 16/9/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MainViewVM.h"
#import "ViewModelCommom.h"
#import "RateObj.h"
#import "Categories.h"
#import "WeightObj.h"
#import "IdentyObj.h"
#import "HightObj.h"
#import "LonelySpkLang.h"
#import "LoginStatusObj.h"

@interface MainViewVM()

@property(nonatomic,strong)NetAccess *netAccess;


@end


@implementation MainViewVM

-(instancetype)init {
    self = [super init];
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    return self;
}

///广播查找
- (void)getAirportListWithBlock:(void(^)(NSArray *arr,BOOL ret,NSString *msg))block andFrom:(NSString*)from andCnt:(NSString*)cnt andTitle:(NSString*)title {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAirportWithSearch:user.userName andPassword:user.password andStart:from andNumbers:cnt andTitle:title andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *boutiqueArr = nil;
            NSString *msg = nil;
            if ([dict[@"code"] intValue] == 1) {
                boutiqueArr = dict[@"data"];
                msg = dict[@"msg"];
                block(boutiqueArr,YES,msg);
            }else{
                msg = dict[@"msg"];
                block(boutiqueArr,NO,msg);
            }
        }else {
            NSString *msg = Local(@"FailedAndPlsRetry");
            block(nil,NO,msg);
        }
    }];
}


- (void)getMianInfoBoutiqueStationListWithBlock:(void(^)(NSArray *arr,BOOL ret,NSString *msg))block andFrom:(NSString*)from andCnt:(NSString*)cnt {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
//    [_netAccess getBoutiqueStationList:<#(NSString *)#> andPassword:<#(NSString *)#> andStart:<#(NSString *)#> andNumbers:<#(NSString *)#> andGender:<#(NSString *)#> andBlock:<#^(NetAccess *server, NSDictionary *dict, BOOL ret)serVerBlock#>];
    [_netAccess  getBoutiqueStationList:user.userName andPassword:user.password andStart:from andNumbers:cnt andGender:user.gender andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *boutiqueArr = nil;
            NSString *msg = nil;
            if ([dict[@"code"] intValue] == 1) {
                boutiqueArr = dict[@"data"];
                msg = dict[@"msg"];
                block(boutiqueArr,YES,msg);
            }else{
                msg = dict[@"msg"];
                block(boutiqueArr,NO,msg);
            }
        }else {
            NSString *msg = Local(@"FailedAndPlsRetry");
            block(nil,NO,msg);

        }
    }];
}

- (void)getMainInfoByCat:(NSString*)cat andSort:(NSString*)sort andFrom:(NSString*)from andCnt:(NSString*)cnt andBlock:(void (^)(NSArray *boutiqueArr,BOOL ret,NSString *msg))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getBoutiqueStationListByCat:user.userName andPassword:user.password andStart:from andNumbers:cnt andCat:cat andSort:sort andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSString *msg = @"";
            NSArray *arr = nil;
            if ([dict[@"code"] intValue] == 1) {
                 arr = dict[@"data"];
            }
            msg = dict[@"msg"];
            block(arr,ret,msg);
        }else{
            block(nil,NO,Local(@"FailedAndPlsRetry"));
        }
    }];
}


///同时请求精品电台和动态，都请求完成之后返回
- (void)getMainInfoNewWithBlock:(void (^)(NSArray *boutiqueArr, NSArray *dynamicArr,BOOL ret,NSString *msg))block andFrom:(NSString *)from andCnt:(NSString *)cnt {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    WS(weakSelf);
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    __block NSArray *boutiqueArr = nil;
    __block NSArray *dynamicArr = nil;
    __block NSString *msg = nil;
    NSString *userName = @"";
    NSString *pwd = @"";
    NSString *gender = @"";
    if (loginStatus.isLogined) {
        userName = user.userName;
        pwd = user.password;
        gender = user.gender;
    }else{
        gender = loginStatus.gender;
    }
    dispatch_group_async(group, queue, ^{
        SS(weakSelf, strongSelf);
        [strongSelf.netAccess  getBoutiqueStationList:userName andPassword:pwd andStart:from andNumbers:cnt andGender:gender  andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
            if (ret && dict) {
                if ([dict[@"code"] intValue] == 1) {
                    boutiqueArr = dict[@"data"];
                }else{
                    msg = dict[@"msg"];
                }
            }
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    });
    dispatch_group_async(group, queue, ^{
        SS(weakSelf, strongSelf);
        [strongSelf.netAccess getMainDynamicList:userName andPassword:pwd andStart:from andNumbers:cnt andGender:gender andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
            if (ret && dict) {
                if ([dict[@"code"] intValue] == 1) {
                    dynamicArr = dict[@"data"];
                }else{
                    msg = dict[@"msg"];
                }
            }
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    });
    dispatch_group_notify(group, queue, ^{
        NSLog(@"请求完成");
        BOOL ret = YES;
        if (boutiqueArr == nil && dynamicArr == nil) {
            ret = NO;
        }
        block(boutiqueArr,dynamicArr,ret,msg);
    });
}


- (void)getEncourageMoneyWithType:(NSString*)type andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getEncourage:user.userName andPassword:user.password andReason:type andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];

}


- (void)getMainInfoWithBlock:(void(^)(NSArray<LonelyStationUser*> *arr,BOOL ret))block  andFrom:(NSString*)from andCnt:(NSString*)cnt {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined == NO) {
        [_netAccess getMainStationListWithNilName:loginStatus.gender andStart:from andNumbers:cnt andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
            if (ret && dict) {
                NSNumber *number = dict[@"code"];
                if ([number intValue] == 1) {
                    NSArray *dataArray = dict[@"data"];
                    NSMutableArray *stationArray = [NSMutableArray array];
                    for (int i = 0; i < dataArray.count; i++) {
                        NSDictionary *dataDict = dataArray[i];
                        LonelyStationUser *stationUser = [[LonelyStationUser alloc] initWithMainDictory:dataDict];
                        [stationArray addObject:stationUser];
                    }
                    block(stationArray,YES);
                }else {
                    block(nil,NO);
                }
            }else {
                block(nil,NO);
            }
        }];
    }else {
        [_netAccess getMainStationList:user.userName andPassword:user.password andStart:from andNumbers:cnt andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
            if (ret && dict) {
                NSNumber *number = dict[@"code"];
                if ([number intValue] == 1) {
                    NSArray *dataArray = dict[@"data"];
                    NSMutableArray *stationArray = [NSMutableArray array];
                    for (int i = 0; i < dataArray.count; i++) {
                        NSDictionary *dataDict = dataArray[i];
                        LonelyStationUser *stationUser = [[LonelyStationUser alloc] initWithMainDictory:dataDict];
                        [stationArray addObject:stationUser];
                    }
                    block(stationArray,YES);
                }else {
                    block(nil,NO);
                }
            }else {
                block(nil,NO);
            }
        }];
    }
}

- (void)getPersonalInfoWithMember:(LonelyStationUser*)user andBlock:(void(^)(NSArray<BoardcastObj*> *arr,BOOL ret))block  andFrom:(NSString*)from andCnt:(NSString*)cnt {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess getAllRecordsWithUser:user.userName andUserId:user.userID andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSDictionary *dataDict = dict[@"data"];
            NSArray *rowArr = dataDict[@"oneRow"];
            NSMutableArray *retArray = [NSMutableArray array];
            if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < rowArr.count; i++) {
                    NSDictionary *recordDict = [rowArr objectAtIndex:i];
                    BoardcastObj *boardcastObj = [[BoardcastObj alloc] initWithDict:recordDict];
                    [retArray addObject:boardcastObj];
                }
            }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                BoardcastObj *boardcastObj = [[BoardcastObj alloc] initWithDict:(NSDictionary*)rowArr];
                [retArray addObject:boardcastObj];
            }
            block(retArray,YES);
            
        }else {
            block(nil,NO);
        }
    } andFrom:from andCnt:cnt];
}


- (void)getAllCateWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAllCateByUserName:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


//检举
- (void)reportActionWithOtherId:(NSString*)otherId andReason:(NSString*)reason andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess reportUserByUserName:user.userName andPassword:user.password andOtherId:otherId andNote:reason andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)careActionWithOtherId:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess addFavorite:user.userName andPassword:user.password andOtherId:otherId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

- (void)deleteCareActionWithOtherId:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteFavorite:user.userName andPassword:user.password andOtherId:otherId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

//收藏
- (void)addCollectWithRecordId:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess addCollect:user.userName andPassword:user.password andRecordId:recordId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];

}

//取消收藏
- (void)deleteCollectWithRecordId:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteCollect:user.userName andPassword:user.password andRecordId:recordId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)getCollectList:(NSString*)from andCnt:(NSString*)cnt andBlock:(void(^)(NSArray *array,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAllCollect:user.userName andPassword:user.password andStart:from andNumber:cnt andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *rowArr = dict[@"data"];
            NSMutableArray *retArray = [NSMutableArray array];
            if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < rowArr.count; i++) {
                    NSDictionary *recordDict = [rowArr objectAtIndex:i];
                    BoardcastObj *boardcastObj = [[BoardcastObj alloc] initWithJSONDict:recordDict];
                    [retArray addObject:boardcastObj];
                }
            }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                BoardcastObj *boardcastObj = [[BoardcastObj alloc] initWithDict:(NSDictionary*)rowArr];
                [retArray addObject:boardcastObj];
            }
            block(retArray,YES);
            
        }else {
            block(nil,NO);
        }

    }];
}


- (void)getFavoriteListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getFavoriteList:user.userName andPassword:user.password andQueryId:user.userID andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    LonelyStationUser *stationUser = [[LonelyStationUser alloc] initWithDictory:dataDict];
                    [stationArray addObject:stationUser];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];

}

- (void)getRateListByRecordId:(NSString*)recordId andBlock:(void(^)(NSArray *array,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getRateList:user.userName andPassword:user.password andRecordId:recordId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *dataArray = dict[@"data"];          NSMutableArray *retArray = [NSMutableArray array];

                if (dataArray && [dataArray isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i < dataArray.count; i++) {
                        NSDictionary *recordDict = [dataArray objectAtIndex:i];
                        RateObj *boardcastObj = [[RateObj alloc] initWithDict:recordDict];
                        [retArray addObject:boardcastObj];
                    }
                    block(retArray,YES);
                }
                
            }else {
                block(nil,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}


- (void)sendRate:(NSString*)recordId andComment:(NSString*)comment andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess addRateToRecord:user.userName andPassword:user.password andRecordId:recordId andComment:comment andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)sayGood:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess addLikeToRecord:user.userName andPassword:user.password andRecordId:recordId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)addlock:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess addLock:user.userName andPassword:user.password andOtherId:otherId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
    
}

//取消封锁
- (void)deleteLock:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteLockUser:user.userName andPassword:user.password andUserId:otherId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}



- (void)getRecordInfo:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getRecordInfo:user.userName andPassword:user.password andRecordId:recordId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

/**
 *  曾经看过
 *
 *  @param userId <#userId description#>
 *  @param block  <#block description#>
 */
- (void)getRecordEvenSeen:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setEvenSeen:user.userName andPassword:user.password andUserId:userId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


/**
 记录听广播

 @param recordId <#recordId description#>
 @param time     <#time description#>
 @param block    <#block description#>
 */
- (void)setRecordSeen:(NSString*)recordId andTime:(NSString*)time andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setSeenWithRecord:recordId andUserName:user.userName andPassword:user.password andListenTimes:time andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


/**
 *  获取全部广播列表
 *
 *  @param block <#block description#>
 *  @param type  <#type description#>
 *  @param from  <#from description#>
 *  @param cnt   <#cnt description#>
 */
- (void)getAllBoardCastWithBlock:(void(^)(NSArray<BoardcastObj*> *arr,BOOL ret))block andBoardCastType:(BoardCastType)type  andFrom:(NSString*)from andCnt:(NSString*)cnt {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMainPageRecords:user.userName andPassword:user.password andStart:from andNumbers:cnt andBoardCastType:type andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *rowArr = dict[@"data"];
            NSMutableArray *retArray = [NSMutableArray array];
            if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < rowArr.count; i++) {
                    NSDictionary *recordDict = [rowArr objectAtIndex:i];
                    BoardcastObj *boardcastObj = [[BoardcastObj alloc] initWithJSONDict:recordDict];
                    [retArray addObject:boardcastObj];
                }
            }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                BoardcastObj *boardcastObj = [[BoardcastObj alloc] initWithJSONDict:(NSDictionary*)rowArr];
                [retArray addObject:boardcastObj];
            }
            block(retArray,YES);
            
        }else {
            block(nil,NO);
        }
 
    }];
}


- (void)getPersonalInfo:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getPersonInfo:user.userName andPassword:user.password andUserId:userId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];

}


- (void)getArticleCatWithBlock:(void(^)(NSArray<Categories*> *arr,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getArticleContent:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *rowArr = dict[@"data"];
            NSMutableArray *retArray = [NSMutableArray array];
            if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < rowArr.count; i++) {
                    NSDictionary *recordDict = [rowArr objectAtIndex:i];
                    Categories *categoriesObj = [[Categories alloc] initWithDict:recordDict];
                    [retArray addObject:categoriesObj];
                }
            }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                 Categories *categoriesObj = [[Categories alloc] initWithDict:(NSDictionary*)rowArr];
                [retArray addObject:categoriesObj];
            }
            block(retArray,YES);
            
        }else {
            block(nil,NO);
        }

    }];
}


- (void)getLangspkWithBlock:(void(^)(NSArray<LonelySpkLang*> *arr,BOOL ret))block {
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


- (void)getCountryListWithBlock:(void(^)(NSArray<LonelyCountry*> *arr,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAllCountry:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *rowArr = dict[@"data"];
                NSMutableArray *retArray = [NSMutableArray array];
                if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i < rowArr.count; i++) {
                        NSDictionary *recordDict = [rowArr objectAtIndex:i];
                        LonelyCountry *countryObj = [[LonelyCountry alloc] initWithJSONDict:recordDict];
                        if ([GETCountryCode isEqualToString:@"zh_cn"]) {
                            if (!([countryObj.countryId isEqualToString:@"128"] || [countryObj.countryId isEqualToString:@"99"] || [countryObj.countryId isEqualToString:@"215"])) {
                                [retArray addObject:countryObj];
                            }
                        }else {
                            [retArray addObject:countryObj];
                        }
                    }
                }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                    LonelyCountry *countryObj = [[LonelyCountry alloc] initWithJSONDict:(NSDictionary*)rowArr];
                    if ([GETCountryCode isEqualToString:@"zh_cn"]) {
                        if (!([countryObj.countryId isEqualToString:@"128"] || [countryObj.countryId isEqualToString:@"99"] || [countryObj.countryId isEqualToString:@"215"])) {
                            [retArray addObject:countryObj];
                        }
                    }else {
                        [retArray addObject:countryObj];
                    }
                }
                block(retArray,YES);
            }else{
                 block(nil,NO);
            }
            
        }else {
            block(nil,NO);
        }
        
    }];

}

- (void)getCityListByCountryId:(NSString*)countryId andBlock:(void(^)(NSArray<LonelyCity*> *arr,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAllCityByCountryId:user.userName andPassword:user.password andCountryId:countryId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *rowArr = dict[@"data"];
                NSMutableArray *retArray = [NSMutableArray array];
                if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i < rowArr.count; i++) {
                        NSDictionary *recordDict = [rowArr objectAtIndex:i];
                        LonelyCity *cityObj = [[LonelyCity alloc] initWithJSONDict:recordDict];
                        cityObj.countryId = countryId;
                        [retArray addObject:cityObj];
                    }
                }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                    LonelyCity *cityObj = [[LonelyCity alloc] initWithJSONDict:(NSDictionary*)rowArr];
                    cityObj.countryId = countryId;
                    [retArray addObject:cityObj];
                }
                block(retArray,YES);
            }else{
                block(nil,NO);
            }
            
        }else {
            block(nil,NO);
        }
    }];
}


- (void)getJobListWithBlock:(void(^)(NSArray<JobObj*> *arr,BOOL ret))block {
     LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *gender = @"M";
    if ([user.gender isEqualToString:@"M"]) {
        gender = @"F";
    }
    [_netAccess getAllJobsByGender:gender andUserName:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            if ([dict[@"code"] intValue] == 1) {
                NSArray *rowArr = dict[@"data"];
                NSMutableArray *retArray = [NSMutableArray array];
                if (rowArr && [rowArr isKindOfClass:[NSArray class]]) {
                    for (int i = 0; i < rowArr.count; i++) {
                        NSDictionary *recordDict = [rowArr objectAtIndex:i];
                        JobObj *job = [[JobObj alloc] initWithJSONDict:recordDict];
                        [retArray addObject:job];
                    }
                }else if(rowArr && [rowArr isKindOfClass:[NSDictionary class]]) {
                    JobObj *cityObj = [[JobObj alloc] initWithJSONDict:(NSDictionary*)rowArr];
                    [retArray addObject:cityObj];
                }
                block(retArray,YES);
            }else{
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getMainListWithSearch:(NSString*)start andNumbers:(NSString*)numbers andFromAge:(NSString*)fromAge andEndAge:(NSString*)endAge andOnline:(NSString*)online andIdentity:(NSString*)identity andSpkLang:(NSString*)countryId andCityId:(NSString*)cityId andJob:(NSString*)jobId andNickName:(NSString*)nickname andCharge:(NSString*)charge andBlock:(void(^)(NSArray<LonelyStationUser*> *arr,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getAdvanceSearchStationList:user.userName andPassword:user.password andStart:start andNumbers:numbers andFromAge:fromAge andToAge:endAge andIsOnline:online andIdentity:identity andCountry:countryId andCity:cityId andJob:jobId andNickName:nickname andCharge:charge andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    LonelyStationUser *stationUser = [[LonelyStationUser alloc] initWithMainDictory:dataDict];
                    [stationArray addObject:stationUser];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


/**
 从分类Id获取所有文章

 @param cateId <#cateId description#>
 @param start  <#start description#>
 @param end    <#end description#>
 @param block  <#block description#>
 */
- (void)getAllArticleWithCateId:(NSString*)cateId andStart:(NSString*)start andEnd:(NSString*)end andBlock:(void(^)(NSArray<ArticleObj*> *arr,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getArticleListByCategoryId:cateId andUserName:user.userName andPassword:user.password andStart:start andNumbers:end andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    ArticleObj *articleObj = [[ArticleObj alloc] initWithDict:dataDict];
                    [stationArray addObject:articleObj];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


/**
 获取某个分类下我的收藏

 @param cateId <#cateId description#>
 @param start  <#start description#>
 @param end    <#end description#>
 @param block  <#block description#>
 */
- (void)getMyCollectionArticleWithCateId:(NSString*)cateId andStart:(NSString*)start andEnd:(NSString*)end andBlock:(void(^)(NSArray<ArticleObj*> *arr,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyCollectArticleWithCatId:cateId andUserName:user.userName andPassword:user.password andStart:start andNumbers:end andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    ArticleObj *articleObj = [[ArticleObj alloc] initWithDict:dataDict];
                    [stationArray addObject:articleObj];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


/**
 获取文章详情By Id

 @param articleId <#articleId description#>
 @param block     <#block description#>
 */
- (void)geArticleDetailWithId:(NSString*)articleId andBlock:(void(^)(ArticleObj *article,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getArticleDetailById:articleId andUserName:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                ArticleObj *articleObj = [[ArticleObj alloc] initWithDict:dict[@"data"]];
                block(articleObj,ret);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}



/**
 把文章加入收藏

 @param articleId <#articleId description#>
 @param block     <#block description#>
 */
- (void)addArticleFavorate:(NSString*)articleId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess addArticleFavoriteWithId:articleId andUserName:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                block(dict,YES);
            }else{
                block(dict,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}



/**
 取消收藏文章

 @param articleId <#articleId description#>
 @param block     <#block description#>
 */
- (void)deleteArticleFavorate:(NSString*)articleId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess cancelArticleFavoriteWithId:articleId andUserName:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                block(dict,YES);
            }else{
                block(dict,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}



- (void)getWeightListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getWeightList:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    WeightObj *articleObj = [[WeightObj alloc] initWithJSONDict:dataDict];
                    [stationArray addObject:articleObj];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getLockListWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getLockList:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                //此处会有个非常牛逼的数组，用-1区分我封锁的人和封锁我的人，-1之前是我封锁的人，-1之后是封锁我的人
                NSMutableDictionary *stationDict = [NSMutableDictionary dictionary];
                NSMutableArray *myLockArray = [NSMutableArray array];
                NSMutableArray *lockMeArray = [NSMutableArray array];
                BOOL isMyLock = YES;
                for (int i = 0; i < dataArray.count; i++) {
                    if ([dataArray[i] intValue] == -1) {
                        isMyLock = NO;
                        continue;
                    }
                    if (isMyLock) {
                        [myLockArray addObject:dataArray[i]];
                    }else {
                        [lockMeArray addObject:dataArray[i]];
                    }
                }
                [stationDict setObject:myLockArray forKey:@"MyLock"];
                [stationDict setObject:lockMeArray forKey:@"LockMe"];
                block(stationDict,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

- (void)getHightListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getHightList:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    HightObj *articleObj = [[HightObj alloc] initWithJSONDict:dataDict];
                    [stationArray addObject:articleObj];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


- (void)getIdentityListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getIdentyList:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    IdentyObj *articleObj = [[IdentyObj alloc] initWithJSONDict:dataDict];
                    [stationArray addObject:articleObj];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取个人信息
- (void)getMyProfileWithBlock:(void(^)(NSDictionary *dic,BOOL ret))block{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyProfile:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *adict, BOOL ret) {
        if (ret && adict) {
            NSNumber *number = adict[@"code"];
            if ([number intValue] == 1) {
                 NSDictionary *dict = adict[@"data"];
                user.userID = NOTNULLObj(dict[@"userid"]);
                user.nickName = NOTNULLObj(dict[@"nickname"]);
                user.slogan = NOTNULLObj(dict[@"slogan"]);
                user.gender = NOTNULLObj(dict[@"gender"]);
                user.identity = NOTNULLObj(dict[@"identity"]);
                user.identityName = NOTNULLObj(dict[@"identity_name"]);
                user.height = NOTNULLObj(dict[@"height"]);
                user.heightId = NOTNULLObj(dict[@"height_id"]);
                user.weight = NOTNULLObj(dict[@"weight"]);
                user.weightId = NOTNULLObj(dict[@"weight_id"]);
                
                user.job = NOTNULLObj(dict[@"occupation"]);
                user.jobId = NOTNULLObj(dict[@"occupation_id"]);

                user.birth_day = NOTNULLObj(dict[@"birth_day"]);
                user.birth_month = NOTNULLObj(dict[@"birth_month"]);
                user.birth_year = NOTNULLObj(dict[@"birth_year"]);
                user.country = NOTNULLObj(dict[@"country"]);
                user.city = NOTNULLObj(dict[@"city"]);
                user.file = NOTNULLObj(dict[@"file"]);
                user.fileStatus = NOTNULLObj(dict[@"file_status"]);
                user.file2 = NOTNULLObj(dict[@"file2"]);
                user.file2Status = NOTNULLObj(dict[@"file2_status"]);
                user.file3 = NOTNULLObj(dict[@"file3"]);
                user.file3Status = NOTNULLObj(dict[@"file3_status"]);
                user.file4 = NOTNULLObj(dict[@"file4"]);
                user.file4Status = NOTNULLObj(dict[@"file4_status"]);
                user.file5 = NOTNULLObj(dict[@"file5"]);
                user.file5Status = NOTNULLObj(dict[@"file5_status"]);
                user.voice = NOTNULLObj(dict[@"voice"]);
                user.voiceStatus = NOTNULLObj(dict[@"voice_status"]);
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                block(dict,YES);
            }else{
                block(nil,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}

- (void)updateProfile:(NSString*)nickName andBirth:(NSString*)birthDay andCountry:(NSString*)country andCity:(NSString*)city andJob:(NSString*)job andSlogan:(NSString*)slogan andHeight:(NSString*)height andWeight:(NSString*)weight andIdentity:(NSString*)identity andBlock:(void(^)(NSDictionary *adict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess updateInfoProfile:user.userName andPassword:user.password andNickName:nickName andBirth:birthDay andCountry:country andCity:city andJob:job andSlogan:slogan andHeight:height andWeight:weight andIdentity:identity andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret){
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                block(dict,YES);
            }else{
                block(dict,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}


- (void)getTelCountryListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    [_netAccess getTelCountryAndIdWithBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSArray *dataArray = dict[@"data"];
            NSMutableArray *stationArray = [NSMutableArray array];
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDict = dataArray[i];
                LonelyCountry *articleObj = [[LonelyCountry alloc] initWithAJSONDict:dataDict];
                [stationArray addObject:articleObj];
            }
            block(stationArray,YES);
        }else{
            block(nil,NO);
        }
    }];
}

//获取验证码
- (void)getSMSCodeWithPhoneCode:(NSString*)phoneCode andPhoneNumber:(NSString*)phoneNumber andBlock:(void(^)(NSDictionary *adict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getSmsCode:user.userName andPassword:user.password andPhoneCode:phoneCode andPhoneNumber:phoneNumber WithBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                block(dict,YES);
            }else{
                block(dict,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}


- (void)validateSMSCode:(NSString*)code andBlock:(void(^)(NSDictionary *adict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess validateSmsCode:user.userName andPassword:user.password andSMSCode:code andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                block(dict,YES);
            }else{
                block(dict,NO);
            }
        }else{
            block(nil,NO);
        }
    }];
}


- (void)getWhoListenMeWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getWhoListenMe:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSArray *dataArray = dict[@"data"];
            NSMutableArray *stationArray = [NSMutableArray array];
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDict = dataArray[i];
                LonelyStationUser *listenUser = [[LonelyStationUser alloc] initWithDictory:dataDict];
                [stationArray addObject:listenUser];
            }
            block(stationArray,YES);
        }else{
            block(nil,NO);
        }
    }];
}

- (void)getWhoCareMeWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getWhoCareMe:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSArray *dataArray = dict[@"data"];
            NSMutableArray *stationArray = [NSMutableArray array];
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDict = dataArray[i];
                LonelyStationUser *listenUser = [[LonelyStationUser alloc] initWithDictory:dataDict];
                [stationArray addObject:listenUser];
            }
            block(stationArray,YES);
        }else{
            block(nil,NO);
        }
    }];
}


- (void)getCallRecordWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getCallRecord:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSArray *dataArray = dict[@"data"];
            NSMutableArray *stationArray = [NSMutableArray array];
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDict = dataArray[i];
                CallRecordObj *callRecordObj = [[CallRecordObj alloc] initWithDict:dataDict];
                [stationArray addObject:callRecordObj];
            }
            block(stationArray,YES);
        }else{
            block(nil,NO);
        }
    }];
}

//获取系统讯息
- (void)getMyNoticeFrom:(NSString*)start andCount:(NSString*)count andBlock:(void(^)(NSArray *array,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyNoticeWithUserName:user.userName andPassword:user.password andStart:start andCount:count andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSArray *dataArray = dict[@"data"];
            NSMutableArray *stationArray = [NSMutableArray array];
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDict = dataArray[i];
                MessageObj *messageObj = [[MessageObj alloc] initWithDict:dataDict];
                [stationArray addObject:messageObj];
            }
            block(stationArray,YES);
        }else{
            block(nil,NO);
        }

    }];
}

- (void)setReadNotice:(NSString*)nid andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setReadNotice:user.userName andPassword:user.password andNid:nid andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];
}


- (void)setAllNoticeReadWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setReadAllNotice:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];
}

- (void)deleteAllNoticeWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteAllNotice:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];
}

- (void)deleteANotice:(NSString*)nid andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteANotice:user.userName andPassword:user.password andNid:nid andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];
}

- (void)getMyTime:(BOOL)isPhoning andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyTime:user.userName andPassword:user.password andIsPhoning:isPhoning andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];

}


- (void)setAuthUser:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setAuthorUser:user.userName andPassword:user.password andUserId:userId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];
    
    
}

- (void)setRecordisCharge:(NSString*)recordId isCharge:(NSString*)isCharge andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess setRecordCharge:user.userName andPassword:user.password andRecordId:recordId andIsCharge:isCharge andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            block(dict,ret);
        }else{
            block(nil,NO);
        }
    }];
}


- (void)getMyGiftListWithBlock:(void(^)(NSArray *array,BOOL ret))block {
    [_netAccess getMyGiftDetail:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSNumber *number = dict[@"code"];
            if ([number intValue] == 1) {
                NSArray *dataArray = dict[@"data"];
                NSMutableArray *stationArray = [NSMutableArray array];
                for (int i = 0; i < dataArray.count; i++) {
                    NSDictionary *dataDict = dataArray[i];
                    LonelyStationUser *stationUser = [[LonelyStationUser alloc] initWithMainDictory:dataDict];
                    [stationArray addObject:stationUser];
                }
                block(stationArray,YES);
            }else {
                block(nil,NO);
            }
        }else {
            block(nil,NO);
        }
    }];
}


@end
