//
//  ChargeVM.m
//  LonelyStation
//
//  Created by 钟铿 on 2019/1/27.
//  Copyright © 2019 zk. All rights reserved.
//

#import "ChargeVM.h"
#import "ViewModelCommom.h"
@interface ChargeVM()

@property (nonatomic,strong)NetAccess *netAccess;

@end


@implementation ChargeVM

-(void)chargeWithLeftCoin:(NSString*)leftCoin andRightCoin:(NSString*)rightCoin andBlock:(void(^)(NSDictionary *dict,BOOL ret))serVerBlock {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [self.netAccess exchangeCoin:user.userName andPassword:user.password andLeft:leftCoin andWithDraw:rightCoin andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(dict,ret);
    }];
}

- (NetAccess*)netAccess {
    if (!_netAccess) {
        _netAccess = [NetAccess new];
    }
    return _netAccess;
}

@end
