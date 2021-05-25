//
//  UploadImgViewModel.m
//  LonelyStation
//
//  Created by zk on 16/5/29.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "UploadImgViewModel.h"
#import "NetAccess.h"
#import "ViewModelCommom.h"

@interface UploadImgViewModel (){
    NetAccess *_netAccess;
}

@end

@implementation UploadImgViewModel

- (void)updateImg:(NSData*)img andProperty:(NSString*)property andSeq:(NSString*)seq andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
   
    [_netAccess uploadAvata:[ViewModelCommom getCurrentEmail] andUserId:[ViewModelCommom getCuttentUserId] andProperty:property andSeq:seq andFileData:img andFileType:@"png" andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


- (void)deleteImgWithSeq:(NSString*)seq andBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess deletePersonalImg:[ViewModelCommom getCurrentEmail] andUserId:[ViewModelCommom getCuttentUserId] andSeq:seq andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}

- (void)getAllImgWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block {
    if (!_netAccess) {
        _netAccess = [[NetAccess alloc] init];
    }
    [_netAccess getAllImg:[ViewModelCommom getCurrentEmail] andUserId:[ViewModelCommom getCuttentUserId] andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        block(dict,ret);
    }];
}


@end
