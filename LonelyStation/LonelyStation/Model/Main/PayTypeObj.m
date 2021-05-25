//
//  PayTypeObj.m
//  LonelyStation
//
//  Created by zk on 2016/12/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "PayTypeObj.h"

@implementation PayTypeObj

- (instancetype)initWithType:(NSString*)type {
    self = [super init];
    _payType = type;
//    if ([type isEqualToString:@"Credit"]) {
//        _payTitle = Local(@"Credit");
//        _isLimitTW = NO;
//        _payImgURL = @"paytype_card.png";
//    }else if ([type isEqualToString:@"ATM"]) {
//        _payTitle = Local(@"ATM");
//        _isLimitTW = YES;
//        _payImgURL = @"paytype_atm.png";
//    }else if ([type isEqualToString:@"CVS"]) {
//        _payTitle = Local(@"CVS");
//        _isLimitTW = YES;
//        _payImgURL = @"paytype_mart.png";
//    }else if ([type isEqualToString:@"In-App"]) {
        _payTitle = Local(@"InAPP");
        _isLimitTW = NO;
        _payImgURL = @"paytype_InApp.png";
//    }
    return self;
}

@end
