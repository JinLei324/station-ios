//
//  LoginViewModel.m
//  LonelyStation
//
//  Created by zk on 16/5/21.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LoginViewModel.h"
#import "LonelyUser.h"
#import "ViewModelCommom.h"

@implementation LoginViewModel

-(void)login:(NSString*)user andPwd:(NSString*)pwd andFlag:(NSString*)flag andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess loginWithName:user andPwd:pwd andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret) {
            if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"userName"];
                LonelyUser *lonelyUser = [[LonelyUser alloc] init];
                lonelyUser.userID =  dict[@"info"][@"mid"][@"text"];
                lonelyUser.file = dict[@"info"][@"file"][@"text"];
                lonelyUser.userName = user;
                lonelyUser.password = pwd;
                lonelyUser.nickName =NOTNULLObj(dict[@"info"][@"nickname"][@"text"]);
                lonelyUser.birthday = [NSString stringWithFormat:@"%@/%@/%@",NOTNULLObj(dict[@"info"][@"birth_year"][@"text"]),NOTNULLObj(dict[@"info"][@"birth_month"][@"text"]),NOTNULLObj(dict[@"info"][@"birth_day"][@"text"])];
                if ([lonelyUser.birthday isEqualToString:@"//"]) {
                    lonelyUser.birthday = @"1990/01/01";
                }
                lonelyUser.birth_day = NOTNULLObj(dict[@"info"][@"birth_day"][@"text"]);
                lonelyUser.birth_month = NOTNULLObj(dict[@"info"][@"birth_month"][@"text"]);
                lonelyUser.birth_year = NOTNULLObj(dict[@"info"][@"birth_year"][@"text"]);
                lonelyUser.voice = NOTNULLObj(dict[@"info"][@"voice"][@"text"]);
                lonelyUser.gender = dict[@"info"][@"gender"][@"text"];
                lonelyUser.unread = [[dict objectForKey:@"unread"] objectForKey:@"text"];
                lonelyUser.talkSecond = dict[@"info"][@"talk_second"][@"text"];
                lonelyUser.radioSecond = dict[@"info"][@"radio_second"][@"text"];
                lonelyUser.vipStartSecond = dict[@"info"][@"vip_start_time"][@"text"];
                lonelyUser.vipEndSecond = dict[@"info"][@"vip_end_time"][@"text"];
                lonelyUser.tooday_frist_login = dict[@"today_frist_login"][@"text"];
                lonelyUser.upload_record_rewards = dict[@"upload_record_rewards"][@"text"];

                NSDictionary *sipInfo = dict[@"sip_info"];
                lonelyUser.slogan = NOTNULLObj(dict[@"info"][@"slogan"][@"text"]);
                lonelyUser.currentLang = NOTNULLObj(dict[@"info"][@"spk_lang"][@"text"]);
                lonelyUser.weight = NOTNULLObj(dict[@"info"][@"weight"][@"text"]);
                lonelyUser.height = NOTNULLObj(dict[@"info"][@"height"][@"text"]);
                lonelyUser.job = NOTNULLObj(dict[@"info"][@"occupation"][@"text"]);
                lonelyUser.country = NOTNULLObj(dict[@"info"][@"country"][@"text"]);
                lonelyUser.countryId = NOTNULLObj(dict[@"info"][@"country_id"][@"text"]);
                
                lonelyUser.city = NOTNULLObj(dict[@"info"][@"city"][@"text"]);
                lonelyUser.cityId = NOTNULLObj(dict[@"info"][@"city_id"][@"text"]);

                lonelyUser.identityName = NOTNULLObj(dict[@"info"][@"identity_name"][@"text"]);
                lonelyUser.identity = NOTNULLObj(dict[@"info"][@"identity"][@"text"]);
                lonelyUser.imtoken = NOTNULLObj(dict[@"info"][@"imtoken"][@"text"]);
                lonelyUser.talkCharge = NOTNULLObj(dict[@"info"][@"talk_charge"][@"text"]);
                lonelyUser.msgCharge = NOTNULLObj(dict[@"info"][@"msg_charge"][@"text"]);
                lonelyUser.chat_point = NOTNULLObj(dict[@"info"][@"chat_point"][@"text"]);
                //写死测试
//                lonelyUser.imtoken = @"X9vy7ECrJUTp/qDtT11aHR9uFdFW5hRc39CodmUA1XH3DVtAd3rsPUhfxuIcoB7F92xCmVIPq7Wp06VP8c1yKA==";
                if (sipInfo) {
                    lonelyUser.sipid = sipInfo[@"account"][@"text"];
                    lonelyUser.sipHost = sipInfo[@"host"][@"text"];
                    lonelyUser.sipPort = sipInfo[@"port"][@"text"];
                }
                [ViewModelCommom setCurrentEmail:lonelyUser.userName];
                [[FileAccessData sharedInstance] setAObject:lonelyUser forEMKey:user];
//                [[AppDelegateModel sharedInstance] startPushAndLoginChat];
//                DLog(@"%@",userObj);
            }
        }
         block(dict,ret);
    }];
}

-(void)forget:(NSString*)user andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess forgetUserName:user andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


-(void)regist:(NSString*)email andPwd:(NSString*)pwd andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess registWithUserName:email andPwd:pwd andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

-(void)registerNext:(NSString*)email andPwd:(NSString*)pwd andGender:(NSString*)gender andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess registerNext:email andPassword:pwd andGender:gender andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


@end
