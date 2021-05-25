//
//  LonelyUser.m
//  LonelyStation
//
//  Created by zk on 16/5/21.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "LonelyUser.h"

@implementation LonelyUser

//@property(nonatomic,copy)NSString *userName;
//@property(nonatomic,copy)NSString *userID;
//@property(nonatomic,copy)NSString *currentHeadImage;//当前头像
//@property(nonatomic,copy)NSString *nickName;//昵称
//@property(nonatomic,copy)NSString *birthday;//生日 yyyy/MM/dd
//@property(nonatomic,copy)NSString *gender;//性别 M/F
//@property(nonatomic,copy)NSString *currentLang;//当前系统语言 zh_tw,zh_cn,en
//@property(nonatomic,copy)NSString *country;//国家
//@property(nonatomic,copy)NSString *city; //城市
//@property(nonatomic,strong)NSMutableDictionary *imagesDict;//获取当前存放的5张照片地址
//@property(nonatomic,strong)NSString *unread;
- (instancetype)initWithDict:(NSDictionary*)dict {
    if (self = [super init]) {
    }
    return self;
}

- (NSString*)getRealFile {
    NSString *realFile = nil;
    if (![_file isEqual:[NSNull null]] && ![@"" isEqualToString:_file]) {
        realFile = _file;
    }else if (![_file2 isEqual:[NSNull null]] && ![@"" isEqualToString:_file2]){
        realFile = _file2;
    }else if (![_file3 isEqual:[NSNull null]] && ![@"" isEqualToString:_file3]){
        realFile = _file3;
    }else if (![_file4 isEqual:[NSNull null]] && ![@"" isEqualToString:_file4]){
        realFile = _file4;
    }else if (![_file5 isEqual:[NSNull null]] && ![@"" isEqualToString:_file5]){
        realFile = _file5;
    }
    return realFile;
}

@end
