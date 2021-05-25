//
//  NetAccess.h
//  LonelyStation
//
//  Created by zk on 15/12/7.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,BoardCastType){
    BoardCastDefault,//最新
    BoardCastLike, //赞最多
    BoardCastMine //我自己的
};


@interface NetAccess : NSObject
/**
 *  登录
 *
 *  @param name        <#name description#>
 *  @param pwd         <#pwd description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)loginWithName:(NSString*)name andPwd:(NSString*)pwd andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  注册
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)registWithUserName:(NSString*)userName andPwd:(NSString*)pwd andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  上传头像
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param property    <#property description#>
 *  @param seq         <#seq description#>
 *  @param fileData    <#fileData description#>
 *  @param type        <#type description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)uploadAvata:(NSString*)userName andUserId:(NSString*)userId andProperty:(NSString*)property andSeq:(NSString*)seq andFileData:(NSData*)fileData andFileType:(NSString*)type andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  忘记密码
 *
 *  @param userName    <#userName description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)forgetUserName:(NSString*)userName andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


- (void)getMainStationListWithNilName:(NSString*)gender andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取国家列表
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)getCountryListWithblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取国家的城市列表
 *
 *  @param countryId  <#countryId description#>
 *  @param serVerBloc <#serVerBloc description#>
 */
-(void)getCityListWithCountry:(NSString*)countryId andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  补充注册信息
 *
 *  @param nickName    <#nickName description#>
 *  @param userId      <#userId description#>
 *  @param email       <#email description#>
 *  @param birthDay    <#birthDay description#>
 *  @param gender      <#gender description#>
 *  @param lang        <#lang description#>
 *  @param country     <#country description#>
 *  @param city        <#city description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)updateInfo:(NSString*)nickName andUserId:(NSString*)userId andUser:(NSString*)email andBirthday:(NSString*)birthDay andGender:(NSString*)gender andLang:(NSString*)lang andCountry:(NSString*)country andCity:(NSString*)city andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取语言
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)getspkListWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;



/**
 获取无限畅聊

 @param userName <#userName description#>
 @param pwd <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getLimitProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  删除公开照和私人照
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param seq         <#seq description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deletePersonalImg:(NSString*)userName andUserId:(NSString*)userId andSeq:(NSString*)seq andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  获取所有公开照和私人照
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllImg:(NSString*)userName andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  获取所有内置背景图片
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getInnerBackImgWithblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取分类
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getCategoryWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  获取背景音乐
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getBgAudioWithblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  上传广播
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param title       <#title description#>
 *  @param imgData     <#imgData description#>
 *  @param imgType     <#imgType description#>
 *  @param audioData   audio的data，现在的都用wav后缀的
 *  @param category    <#category description#>
 *  @param effectFile1 <#effectFile1 description#>
 *  @param effectTime1 <#effectTime1 description#>
 *  @param effectFile2 <#effectFile2 description#>
 *  @param effectTime2 <#effectTime2 description#>
 *  @param serVerBlock <#serVerBlock description#>
 *  @param isCharge
 */
- (void)uploadRecordWithMember:(NSString*)userName andUserId:(NSString*)userId andTitle:(NSString*)title andImage:(NSData*)imgData andImgType:(NSString*)imgType andAudio:(NSData*)audioData category:(NSString*)category andEffectFile1:(NSString*)effectFile1 andEffectFile1StartTime:(NSString*)effectTime1 andEffectFile2:(NSString*)effectFile2 andEffectFile2StartTime:(NSString*)effectTime2 andDuration:(int)duration andIsCharge:(NSString*)isCharge andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取个人所有电台
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllRecordsWithUser:(NSString*)userName andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock andFrom:(NSString *)from andCnt:(NSString*)cnt;

/**
 *  删除广播
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deleteRecordWithUser:(NSString*)userName andUserId:(NSString*)userId andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取首页列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainStationList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  取得某人的自我介绍档案
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param queryId     <#queryId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getIntroduceVoice:(NSString*)userName andPassword:(NSString*)pwd andQueryId:(NSString*)queryId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;



/**
 *  送礼
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param time        <#time description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)sendGift:(NSString*)userName andPassword:(NSString*)pwd andRecieveUserId:otherUserId andAmount:(NSString*)time andServerBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  获取通话时间
 *
 *  @param sipId1      <#sipId1 description#>
 *  @param pwd         <#pwd description#>
 *  @param host
 *  @param sipId2      <#sipId2 description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getTalkMinutesWithSipID1:(NSString*)sipId1 andHost:(NSString*)host andPassword:(NSString*)pwd andSipId2:(NSString*)sipId2  andServerBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  将通话时间传给appServer
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param sipId1      <#sipId1 description#>
 *  @param sipId2      <#sipId2 description#>
 *  @param callDate    <#callDate description#>
 *  @param billSec     <#billSec description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)transferTimeToServer:(NSString*)userName andPassword:(NSString*)pwd andSipId1:(NSString*)sipId1 andSipId2:(NSString*)sipId2 andCallDate:(NSString*)callDate andBillSec:(NSString*)billSec andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  获取用户信息by sipid
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param sipId       <#sipId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getUserBySipId:(NSString*)userName andPassword:(NSString*)pwd andSipId:(NSString*)sipId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  检举用户
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)reportUserByUserName:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andNote:(NSString*)note andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  加入关注
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addFavorite:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  取消关注
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deleteFavorite:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  加入封锁
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addLock:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取所有关注列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param queryId     <#queryId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getFavoriteList:(NSString*)userName andPassword:(NSString*)pwd andQueryId:(NSString*)queryId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  收藏某一则广播
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addCollect:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  取消收藏某一则广播
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deleteCollect:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  取得我的收藏列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param number      <#number description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllCollect:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumber:(NSString*)number  andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  添加广播点赞
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addLikeToRecord:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  添加广播评论
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param comment     <#comment description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addRateToRecord:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andComment:(NSString*)comment andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取评论列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getRateList:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  获取广播的基本信息
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getRecordInfo:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取全部广播
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param type        <#type description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainPageRecords:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBoardCastType:(BoardCastType)type andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 *  设置曾经看过
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)setEvenSeen:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取用户基本资讯
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getPersonInfo:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 获取现有上线类别
 
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAliveCat:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 获取分类照片
 
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getArticleContent:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 获取所有国家，其实就是进阶搜寻里获取语言
 
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllCountry:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 根据国家Id获取城市
 
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param countryId   <#countryId description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllCityByCountryId:(NSString*)userName andPassword:(NSString*)pwd andCountryId:(NSString*)countryId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 获取职业用性别
 
 @param gender      <#gender description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllJobsByGender:(NSString*)gender andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 进阶搜寻

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param start       <#start description#>
 @param numbers     <#numbers description#>
 @param fromAge     <#fromAge description#>
 @param toAge       <#toAge description#>
 @param isOnline    <#isOnline description#>
 @param identity    <#identity description#>
 @param countryId   <#countryId description#>
 @param cityId      <#cityId description#>
 @param jobId       <#jobId description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAdvanceSearchStationList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andFromAge:(NSString*)fromAge andToAge:(NSString*)toAge andIsOnline:(NSString*)isOnline andIdentity:(NSString*)identity andCountry:(NSString*)countryId andCity:(NSString*)cityId andJob:(NSString*)jobId andNickName:(NSString*)nickname andCharge:(NSString*)charge  andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 获取分类下的文章
 
 @param cateId      <#cateId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param start       <#start description#>
 @param numbers     <#numbers description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getArticleListByCategoryId:(NSString*)cateId andUserName:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 获取文章详情
 
 @param articleId   <#articleId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getArticleDetailById:(NSString*)articleId andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 获取某个分类我的收藏
 
 @param cateId      <#cateId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param start       <#start description#>
 @param numbers     <#numbers description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getMyCollectArticleWithCatId:(NSString*)cateId andUserName:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 文章加入收藏
 
 @param articleId   <#articleId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)addArticleFavoriteWithId:(NSString*)articleId andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;





/**
 取消收藏文章
 
 @param articleId   <#articleId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)cancelArticleFavoriteWithId:(NSString*)articleId andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 设置听过录音
 
 @param recordId    <#recordId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param time        <#time description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)setSeenWithRecord:(NSString*)recordId andUserName:(NSString*)userName andPassword:(NSString*)pwd andListenTimes:(NSString*)time andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
 获取我的音库
 
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getMyVoices:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;




/**
 上传自介音档和罐头音
 
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param fileData    <#fileData description#>
 @param seq         <#seq description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)uploadVoice:(NSString*)userName andPassword:(NSString*)pwd andAudio:(NSData*)fileData andSeq:(NSString*)seq andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


- (void)getWeightList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


- (void)getIdentyList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


//更新个人信息
- (void)updateInfoProfile:(NSString*)userName andPassword:(NSString*)pwd andNickName:(NSString*)nickName andBirth:(NSString*)birthDay andCountry:(NSString*)country andCity:(NSString*)city andJob:(NSString*)job andSlogan:(NSString*)slogan andHeight:(NSString*)height andWeight:(NSString*)weight andIdentity:(NSString*)identity andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取个人信息
- (void)getMyProfile:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取国家和国码
- (void)getTelCountryAndIdWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取封锁信息
- (void)getLockList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取身高信息
- (void)getHightList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取验证码
- (void)getSmsCode:(NSString*)userName andPassword:(NSString*)pwd andPhoneCode:(NSString*)phoneCode andPhoneNumber:(NSString*)phoneNumer WithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//验证验证码
- (void)validateSmsCode:(NSString*)userName andPassword:(NSString*)pwd andSMSCode:(NSString*)SMSCode andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//谁来听我
- (void)getWhoListenMe:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//谁关注我
- (void)getWhoCareMe:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//通话记录
- (void)getCallRecord:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取系统讯息
- (void)getMyNoticeWithUserName:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andCount:(NSString*)count andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//设置一则消息为读取
- (void)setReadNotice:(NSString*)userName andPassword:(NSString*)pwd andNid:(NSString*)nid andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;



//设置全部消息为读取
- (void)setReadAllNotice:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//删除一则消息
- (void)deleteANotice:(NSString*)userName andPassword:(NSString*)pwd andNid:(NSString*)nid andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取自己的所有电台
- (void)getMyRecordsWithUser:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock andFrom:(NSString *)from andCnt:(NSString*)cnt;


//删除所有消息
- (void)deleteAllNotice:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取个人设置
- (void)getNotifySetting:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//修改个人设置
- (void)updateNotifySetting:(NSString*)userName andPassword:(NSString*)pwd andField:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取我的授权列表
- (void)getMyAuthorList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//授权某人
- (void)setAuthorUser:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//取消授权某人
- (void)deleteAuthorUser:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取我的封锁列表
- (void)getMyLockList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//取消封锁某人
- (void)deleteLockUser:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取问答
- (void)getQuestAndAnswer:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取套餐方案
- (void)getComboProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取聊天卡方案
- (void)getTalkProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


//获取电台劵方案
- (void)getRadioProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//取得订单号码和资讯
- (void)getOrderDetail:(NSString*)userName andPassword:(NSString*)pwd andPrice:(NSString*)price andBuyTalkSecond:(NSString*)talkSeconds andRaidoSecond:(NSString*)radioSeconds andChatPoint:(NSString*)chatPoint andSubject:(NSString*)subject andBody:(NSString*)body andPayType:(NSString*)payType andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取所有订单
- (void)getAllOrders:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//修改密码
- (void)changePwd:(NSString*)userName andPassword:(NSString*)pwd andNewPwd:(NSString*)newPwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//自行删除账号
- (void)deleteSelf:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//取得收益内容
- (void)getProfit:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//取得收益明细
- (void)getProfitDetail:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//执行提领
- (void)doWithDraw:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//提领记录清单
- (void)withDrawList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//更新提领设置
- (void)updateWithDrawSetting:(NSString*)userName andPassword:(NSString*)pwd andCurrent:(NSString*)current andAccount:(NSString*)account andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//收益兌換聊天卡、電台券 資訊
- (void)getChangeDetail:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//执行兑换
- (void)doExchange:(NSString*)userName andPassword:(NSString*)pwd andChangeTalkSecond:(NSString*)talkSecond andRadioSecond:(NSString*)radioSecond andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//领取聊币
- (void)getEncourage:(NSString*)userName andPassword:(NSString*)pwd andReason:(NSString*)reason andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//兑换聊币
- (void)exchangeCoin:(NSString*)userName andPassword:(NSString*)pwd andLeft:(NSString*)reason andWithDraw:(NSString*)withDraw andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


//获取订单交易结果
- (void)getTradeStatus:(NSString*)userName andPassword:(NSString*)pwd andOrderId:(NSString*)orderId andReceipt:(NSString*)receipt andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

///获取最新聊币
- (void)getMyTime:(NSString*)userName andPassword:(NSString*)pwd andIsPhoning:(BOOL)isPhoning  andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//传送消息
- (void)insertMessage:(NSString*)userName andPassword:(NSString*)pwd andToMember:(NSString*)toUserId andMsgType:(NSString*)type andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取审核状态
- (void)getCheckingStatusWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取今日收益
- (void)getMyProfileTodayDetail:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//获取当月收益
- (void)getMyProfileMonthDetail:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


//获取我的礼物
- (void)getMyGiftDetail:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

//设置是否收费
- (void)setRecordCharge:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andIsCharge:(NSString*)isCharge andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


/**
注册的下一步

 @param userName <#userName description#>
 @param pwd <#pwd description#>
 @param gender <#gender description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)registerNext:(NSString*)userName andPassword:(NSString*)pwd andGender:(NSString*)gender andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;


- (void)updateNotifyChargeSetting:(NSString*)userName andPassword:(NSString*)pwd andField:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取情人动态列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainDynamicList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andGender:(NSString*)gender andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

///查找广播
- (void)getAirportWithSearch:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andTitle:(NSString*)title andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

/**
 *  获取精品电台列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getBoutiqueStationList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andGender:(NSString*)gender andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

///获取所有分类
- (void)getAllCateByUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

///按分类获取广播
- (void)getBoutiqueStationListByCat:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andCat:(NSString*)cat andSort:(NSString*)sort andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock;

@end
