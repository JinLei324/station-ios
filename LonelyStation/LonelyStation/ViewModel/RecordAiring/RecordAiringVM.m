//
//  RecordAiringVM.m
//  LonelyStation
//
//  Created by zk on 16/8/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "RecordAiringVM.h"
#import "LonelyUser.h"
#import "ViewModelCommom.h"

@interface RecordAiringVM (){
    NetAccess *_netAccess;
}

@end

@implementation RecordAiringVM

- (instancetype)init {
    self = [super init];
    _netAccess = [[NetAccess alloc] init];
    return self;
}

//获取内置图片
- (void)getInnerImgWithBlock:(void(^)(NSArray<InnerRecBgImgObj*> *arr,BOOL ret))block {
    [_netAccess getInnerBackImgWithblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *imgObjArr = [dict objectForKey:@"oneRow"];
            if (imgObjArr && [imgObjArr isKindOfClass:[NSArray class]]) {
                NSMutableArray *imgArr = [NSMutableArray array];
                for (int i = 0; i < imgObjArr.count; i++) {
                    NSDictionary *imgDict = [imgObjArr objectAtIndex:i];
                    InnerRecBgImgObj *innerRec = [[InnerRecBgImgObj alloc] initWithDict:imgDict];
                    [imgArr addObject:innerRec];
                }
                block(imgArr,YES);
            }
        }else {
            block(nil,NO);
        }
    }];
}

NSInteger bigCateSort(id obj1, id obj2,void* context){
    RecordBigCategoryObj *cate1 = (RecordBigCategoryObj*)obj1;
    RecordBigCategoryObj *cate2 = (RecordBigCategoryObj*)obj2;
    return (NSComparisonResult)([cate1.categoryId intValue] > [cate2.categoryId intValue]);
}

NSInteger cateSort(id obj1, id obj2,void* context){
    RecordCategoryObj *cate1 = (RecordCategoryObj*)obj1;
    RecordCategoryObj *cate2 = (RecordCategoryObj*)obj2;
    return (NSComparisonResult)([cate1.categoryId intValue] < [cate2.categoryId intValue]);
}

//获取分类
- (void)getCategoryWithBlock:(void(^)(NSArray<RecordBigCategoryObj*> *arr,BOOL ret))block {
    [_netAccess getCategoryWithBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            if([dict isKindOfClass:[NSArray class]]){
                NSArray *imgObjArr = (NSArray*)dict;
                if (imgObjArr && [imgObjArr isKindOfClass:[NSArray class]]) {
                    NSMutableArray *imgArr = [NSMutableArray array];
                    //第一个是大类，后面的是小类
                    for (int i = 0; i < imgObjArr.count; i++) {
                        if (i == 0) {
                            NSDictionary *bigCategoryDict = imgObjArr[0];
                            for (int j = 0; j < bigCategoryDict.allKeys.count; j++) {
                                RecordBigCategoryObj *bigCategory = [[RecordBigCategoryObj alloc] init];
                                bigCategory.categoryId = bigCategoryDict.allKeys[j];
                                bigCategory.categoryName = bigCategoryDict[bigCategory.categoryId];
                                [imgArr addObject:bigCategory];
                            }
                            //从小到大排序
                            [imgArr sortUsingFunction:bigCateSort context:nil];
                        }else {
                            NSDictionary *categoryDict = imgObjArr[i];
                            RecordBigCategoryObj *bigCategory = imgArr[i-1];
                            NSMutableArray *catArr = [NSMutableArray array];
                            for (int j = 0; j < categoryDict.allKeys.count; j++) {
                                RecordCategoryObj *category = [[RecordCategoryObj alloc] init];
                                category.categoryId = categoryDict.allKeys[j];
                                category.categoryName = categoryDict[category.categoryId];
                                [catArr addObject:category];
                            }
                            [catArr sortUsingFunction:bigCateSort context:nil];
                            bigCategory.categoryArr = catArr;
                        }
                    }
                    block(imgArr,YES);
                }
            }
        }else {
            block(nil,NO);
        }
    }];
}

//获取背景音乐
- (void)getEffectWithBlock:(void(^)(NSArray<BgAudioObj*> *arr,BOOL ret))block {
    [_netAccess getBgAudioWithblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *effectObjArr = dict[@"oneRow"];
            if (effectObjArr && [effectObjArr isKindOfClass:[NSArray class]]) {
                NSMutableArray *effectArr = [NSMutableArray array];
                //遍历array
                for (int i = 0; i < effectObjArr.count; i++) {
                    NSDictionary *effectDict = effectObjArr[i];
                    BgAudioObj *bgAudioObj = [[BgAudioObj alloc] initWithDict:effectDict];
                    [effectArr addObject:bgAudioObj];
                }
                block(effectArr,YES);
            }
        }else {
            block(nil,NO);
        }
    }];
}

//发布广播
- (void)publicRecordAiring:(NSString*)title andImage:(NSData*)imgData andImgType:(NSString*)imgType andAudio:(NSData*)audioData category:(NSString*)category andEffectFile1:(NSString*)effectFile1 andEffectFile1StartTime:(NSString*)effectTime1 andEffectFile2:(NSString*)effectFile2 andEffectFile2StartTime:(NSString*)effectTime2 andDuration:(int)duration andIsCharge:(NSString*)isCharge andBlock:(void(^)(NSDictionary *dict))block {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess uploadRecordWithMember:user.userName andUserId:user.userID andTitle:title andImage:imgData andImgType:imgType andAudio:audioData category:category andEffectFile1:effectFile1 andEffectFile1StartTime:effectTime1 andEffectFile2:effectFile2 andEffectFile2StartTime:effectTime2 andDuration:duration andIsCharge:isCharge andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSDictionary *retDict = @{@"code":dict[@"code"][@"text"],@"msg":dict[@"msg"][@"text"]};
            block(retDict);
        }else {
            block(nil);
        }
        
    }];
}

//获取所有广播
- (void)getAllRecordAiringWithBlock:(void(^)(NSArray<BoardcastObj*> *arr,BOOL ret))block  andFrom:(NSString*)from andCnt:(NSString*)cnt{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess getMyRecordsWithUser:user.userName andPassword:user.password andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (ret && dict) {
            NSArray *dataArray = dict[@"data"];
            NSMutableArray *stationArray = [NSMutableArray array];
            for (int i = 0; i < dataArray.count; i++) {
                NSDictionary *dataDict = dataArray[i];
                BoardcastObj *messageObj = [[BoardcastObj alloc] initWithJSONDict:dataDict];
                [stationArray addObject:messageObj];
            }
            block(stationArray,YES);
        }else{
            block(nil,NO);
        }
    } andFrom:from andCnt:cnt];
}

//删除广播
- (void)deleteRecordWithRecordId:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_netAccess deleteRecordWithUser:user.userName andUserId:user.userID andRecordId:recordId andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            NSDictionary *retDict = @{@"code":dict[@"code"][@"text"],@"msg":dict[@"msg"][@"text"]};
            block(retDict,YES);
        }else {
            block(nil,NO);
        }
    }];
}

@end
