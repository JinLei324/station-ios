//
//  PayTypeObj.h
//  LonelyStation
//
//  Created by zk on 2016/12/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface PayTypeObj : EMObject

@property(nonatomic,copy)NSString *payType;
@property(nonatomic,copy)NSString *payImgURL;
@property(nonatomic,copy)NSString *payTitle;
@property(nonatomic,assign)BOOL isLimitTW;

- (instancetype)initWithType:(NSString*)type;

@end
