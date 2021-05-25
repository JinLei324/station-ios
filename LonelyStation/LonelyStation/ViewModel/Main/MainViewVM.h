//
//  MainViewVM.h
//  LonelyStation
//
//  Created by zk on 16/9/4.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import "LonelyStationUser.h"
#import "NetAccess.h"
#import "Categories.h"
#import "LonelyCity.h"
#import "LonelyCountry.h"
#import "JobObj.h"
#import "ArticleObj.h"
#import "LonelySpkLang.h"
#import "CallRecordObj.h"
#import "MessageObj.h"

@interface MainViewVM : EMObject

///获取奖励的币type 1.登录 3.广播
- (void)getEncourageMoneyWithType:(NSString*)type andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


//获取主页数据
- (void)getMainInfoWithBlock:(void(^)(NSArray<LonelyStationUser*> *arr,BOOL ret))block  andFrom:(NSString*)from andCnt:(NSString*)cnt;

//获取某个人的电台
- (void)getPersonalInfoWithMember:(LonelyStationUser*)user andBlock:(void(^)(NSArray<BoardcastObj*> *arr,BOOL ret))block  andFrom:(NSString*)from andCnt:(NSString*)cnt;


- (void)getLockListWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

/**
 *  获取某人基本资讯
 *
 *  @param userId <#userId description#>
 *  @param block  <#block description#>
 */
- (void)getPersonalInfo:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

/**
 *  获取全部广播列表
 *
 *  @param block <#block description#>
 *  @param from  <#from description#>
 *  @param cnt   <#cnt description#>
 */
- (void)getAllBoardCastWithBlock:(void(^)(NSArray<BoardcastObj*> *arr,BOOL ret))block andBoardCastType:(BoardCastType)type andFrom:(NSString*)from andCnt:(NSString*)cnt;


///获取全部分类
- (void)getAllCateWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 *  检举某人
 *
 *  @param otherId <#otherId description#>
 *  @param reason  <#reason description#>
 *  @param block   <#block description#>
 */
- (void)reportActionWithOtherId:(NSString*)otherId andReason:(NSString*)reason andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

/**
 *  加入关注
 *
 *  @param otherId <#otherId description#>
 *  @param block   <#block description#>
 */
- (void)careActionWithOtherId:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 *  获取关注列表
 *
 *  @param block <#block description#>
 */
- (void)getFavoriteListWithBlock:(void(^)(NSArray *array,BOOL ret))block;
/**
 *  取消关注
 *
 *  @param otherId otherId description
 *  @param block   <#block description#>
 */
- (void)deleteCareActionWithOtherId:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 *  加入收藏
 *
 *  @param recordId <#recordId description#>
 *  @param block    <#block description#>
 */
- (void)addCollectWithRecordId:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 *  取消收藏
 *
 *  @param recordId <#recordId description#>
 *  @param block    <#block description#>
 */
- (void)deleteCollectWithRecordId:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

/**
 *  获取所有收藏的广播
 *
 *  @param from  <#from description#>
 *  @param cnt   <#cnt description#>
 *  @param block <#block description#>
 */
- (void)getCollectList:(NSString*)from andCnt:(NSString*)cnt andBlock:(void(^)(NSArray *array,BOOL ret))block;

/**
 *  获取某个广播的所有评论
 *
 *  @param recordId <#recordId description#>
 *  @param block    <#block description#>
 */
- (void)getRateListByRecordId:(NSString*)recordId andBlock:(void(^)(NSArray *array,BOOL ret))block;

/**
 *  添加评论
 *
 *  @param recordId <#recordId description#>
 *  @param comment  <#comment description#>
 *  @param block    <#block description#>
 */
- (void)sendRate:(NSString*)recordId andComment:(NSString*)comment andBlock:(void(^)(NSDictionary *dict,BOOL ret))block ;

/**
 *  点赞
 *
 *  @param recordId <#recordId description#>
 *  @param block    <#block description#>
 */
- (void)sayGood:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 *  获取广播的基本信息
 *
 *  @param recordId <#recordId description#>
 *  @param block    <#block description#>
 */
- (void)getRecordInfo:(NSString*)recordId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

/**
 *  加入封锁
 *
 *  @param otherId <#otherId description#>
 *  @param block   <#block description#>
 */
- (void)addlock:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block ;




/**
 *  曾经看过
 *
 *  @param userId <#userId description#>
 *  @param block  <#block description#>
 */
- (void)getRecordEvenSeen:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 获取类别

 @param block <#block description#>
 */
- (void)getArticleCatWithBlock:(void(^)(NSArray<Categories*> *arr,BOOL ret))block;


/**
 获取国家

 @param block <#block description#>
 */
- (void)getCountryListWithBlock:(void(^)(NSArray<LonelyCountry*> *arr,BOOL ret))block;


/**
 获取国家对应的所有城市

 @param countryId <#countryId description#>
 @param block     <#block description#>
 */
- (void)getCityListByCountryId:(NSString*)countryId andBlock:(void(^)(NSArray<LonelyCity*> *arr,BOOL ret))block;


/**
 获取所有职业

 @param block <#block description#>
 */
- (void)getJobListWithBlock:(void(^)(NSArray<JobObj*> *arr,BOOL ret))block;


/**
  获取进阶搜寻

 @param start     <#start description#>
 @param numbers   <#numbers description#>
 @param fromAge   <#fromAge description#>
 @param endAge    <#endAge description#>
 @param online    <#online description#>
 @param identity  <#identity description#>
 @param countryId <#countryId description#>
 @param cityId    <#cityId description#>
 @param jobId     <#jobId description#>
 @param block     <#block description#>
 */
- (void)getMainListWithSearch:(NSString*)start andNumbers:(NSString*)numbers andFromAge:(NSString*)fromAge andEndAge:(NSString*)endAge andOnline:(NSString*)online andIdentity:(NSString*)identity andSpkLang:(NSString*)countryId andCityId:(NSString*)cityId andJob:(NSString*)jobId andNickName:(NSString*)nickname andCharge:(NSString*)charge andBlock:(void(^)(NSArray<LonelyStationUser*> *arr,BOOL ret))block;


/**
 从分类Id获取所有文章
 
 @param cateId <#cateId description#>
 @param start  <#start description#>
 @param end    <#end description#>
 @param block  <#block description#>
 */
- (void)getAllArticleWithCateId:(NSString*)cateId andStart:(NSString*)start andEnd:(NSString*)end andBlock:(void(^)(NSArray<ArticleObj*> *arr,BOOL ret))block;


/**
 记录听广播
 
 @param recordId <#recordId description#>
 @param time     <#time description#>
 @param block    <#block description#>
 */
- (void)setRecordSeen:(NSString*)recordId andTime:(NSString*)time andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 获取某个分类下我的收藏
 
 @param cateId <#cateId description#>
 @param start  <#start description#>
 @param end    <#end description#>
 @param block  <#block description#>
 */
- (void)getMyCollectionArticleWithCateId:(NSString*)cateId andStart:(NSString*)start andEnd:(NSString*)end andBlock:(void(^)(NSArray<ArticleObj*> *arr,BOOL ret))block;


/**
 获取文章详情By Id
 @param articleId <#articleId description#>
 @param block     <#block description#>
 */
- (void)geArticleDetailWithId:(NSString*)articleId andBlock:(void(^)(ArticleObj *article,BOOL ret))block;

/**
 把文章加入收藏
 
 @param articleId <#articleId description#>
 @param block     <#block description#>
 */
- (void)addArticleFavorate:(NSString*)articleId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

/**
 取消收藏文章
 
 @param articleId <#articleId description#>
 @param block     <#block description#>
 */
- (void)deleteArticleFavorate:(NSString*)articleId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


/**
 获取identity
 
 @param block     <#block description#>
 */
- (void)getIdentityListWithBlock:(void(^)(NSArray *array,BOOL ret))block;






- (void)getLangspkWithBlock:(void(^)(NSArray<LonelySpkLang*> *arr,BOOL ret))block;

/**
 获取weight
 
 @param block     <#block description#>
 */
- (void)getWeightListWithBlock:(void(^)(NSArray *array,BOOL ret))block;


- (void)getHightListWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取个人信息
- (void)getMyProfileWithBlock:(void(^)(NSDictionary *dic,BOOL ret))block;

//更新个人信息
- (void)updateProfile:(NSString*)nickName andBirth:(NSString*)birthDay andCountry:(NSString*)country andCity:(NSString*)city andJob:(NSString*)job andSlogan:(NSString*)slogan andHeight:(NSString*)height andWeight:(NSString*)weight andIdentity:(NSString*)identity andBlock:(void(^)(NSDictionary *adict,BOOL ret))block;

//获取国码和国名
- (void)getTelCountryListWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取验证码
- (void)getSMSCodeWithPhoneCode:(NSString*)phoneCode andPhoneNumber:(NSString*)phoneNumber andBlock:(void(^)(NSDictionary *adict,BOOL ret))block;

//验证验证码
- (void)validateSMSCode:(NSString*)code andBlock:(void(^)(NSDictionary *adict,BOOL ret))block;

//获取谁来听我
- (void)getWhoListenMeWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取谁关注我
- (void)getWhoCareMeWithBlock:(void(^)(NSArray *array,BOOL ret))block;

//获取我的通话记录
- (void)getCallRecordWithBlock:(void(^)(NSArray *array,BOOL ret))block;


//获取系统讯息
- (void)getMyNoticeFrom:(NSString*)start andCount:(NSString*)count andBlock:(void(^)(NSArray *array,BOOL ret))block;

//设置已读
- (void)setReadNotice:(NSString*)nid andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//设置全部已读
- (void)setAllNoticeReadWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//删除单则消息
- (void)deleteANotice:(NSString*)nid andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//删除所有消息
- (void)deleteAllNoticeWithBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


//获取我的电台劵和通话劵时间
- (void)getMyTime:(BOOL)isPhoning andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//取消封锁
- (void)deleteLock:(NSString*)otherId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//授权某人
- (void)setAuthUser:(NSString*)userId andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;

//设置是否收费
- (void)setRecordisCharge:(NSString*)recordId isCharge:(NSString*)isCharge andBlock:(void(^)(NSDictionary *dict,BOOL ret))block;


- (void)getMainInfoNewWithBlock:(void (^)(NSArray *boutiqueArr, NSArray *dynamicArr,BOOL ret,NSString *msg))block andFrom:(NSString *)from andCnt:(NSString *)cnt;

///获取精品电台
- (void)getMianInfoBoutiqueStationListWithBlock:(void(^)(NSArray *arr,BOOL ret,NSString *msg))block andFrom:(NSString*)from andCnt:(NSString*)cnt;

///获取电台用分类
- (void)getMainInfoByCat:(NSString*)cat andSort:(NSString*)sort andFrom:(NSString*)from andCnt:(NSString*)cnt andBlock:(void (^)(NSArray *boutiqueArr,BOOL ret,NSString *msg))block;

///广播查找
- (void)getAirportListWithBlock:(void(^)(NSArray *arr,BOOL ret,NSString *msg))block andFrom:(NSString*)from andCnt:(NSString*)cnt andTitle:(NSString*)title;

/**
 *  获取我的礼物
 *
 *  @param block <#block description#>
 */
- (void)getMyGiftListWithBlock:(void(^)(NSArray *array,BOOL ret))block;

@end
