//
//  UploadImgViewModel.h
//  LonelyStation
//
//  Created by zk on 16/5/29.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface UploadImgViewModel : EMObject

- (void)updateImg:(NSData*)img andProperty:(NSString*)property andSeq:(NSString*)seq andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)deleteImgWithSeq:(NSString*)seq andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

- (void)getAllImgWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

@end
