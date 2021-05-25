//
//  ChargeVM.h
//  LonelyStation
//
//  Created by 钟铿 on 2019/1/27.
//  Copyright © 2019 zk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChargeVM : NSObject

-(void)chargeWithLeftCoin:(NSString*)leftCoin andRightCoin:(NSString*)rightCoin andBlock:(void(^)(NSDictionary *dict,BOOL ret))serVerBlock;

@end

NS_ASSUME_NONNULL_END
