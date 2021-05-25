//
//  RecordAiringVM.h
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "InnerRecBgImgObj.h"
#import "RecordBigCategoryObj.h"
#import "BgAudioObj.h"
#import "BoardcastObj.h"

@interface RecordAiringVM : EMObject

//获取内置图片
- (void)getInnerImgWithBlock:(void(^)(NSArray<InnerRecBgImgObj*> *arr,BOOL ret))block;

//获取录音分类
- (void)getCategoryWithBlock:(void(^)(NSArray<RecordBigCategoryObj*> *arr,BOOL ret))block;

//获取背景音乐
- (void)getEffectWithBlock:(void(^)(NSArray<BgAudioObj*> *arr,BOOL ret))block;

//发布广播
- (void)publicRecordAiring:(NSString*)title andImage:(NSData*)imgData andImgType:(NSString*)imgType andAudio:(NSData*)audioData category:(NSString*)category andEffectFile1:(NSString*)effectFile1 andEffectFile1StartTime:(NSString*)effectTime1 andEffectFile2:(NSString*)effectFile2 andEffectFile2StartTime:(NSString*)effectTime2 andDuration:(int)duration andIsCharge:(NSString*)isCharge andBlock:(void(^)(NSDictionary *dict))block ;

//获取所有广播
- (void)getAllRecordAiringWithBlock:(void(^)(NSArray<BoardcastObj*> *arr,BOOL ret))block andFrom:(NSString*)from andCnt:(NSString*)cnt;

//删除广播
- (void)deleteRecordWithRecordId:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


@end
