//
//  NetAccess.m
//  LonelyStation
//
//  Created by zk on 15/12/7.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "NetAccess.h"
#import "AFNetworking.h"
#import "SvUDIDTools.h"
#import <CommonCrypto/CommonDigest.h>
#import "XMLReader.h"
#define PARSEHEADER @"<zkParse>"
#define PARSEFOOTER @"</zkParse>"
#define PARSEKEY @"zkParse"
#define SEED @"lover"

@interface NetAccess()

@property (nonatomic,assign)int connectCount;

@end

@implementation NetAccess

-(AFHTTPRequestOperationManager*)createAFHTTPRequestOperationManager{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //自签名证书,他们在技术上“无效”,所以我们需要允许:
    manager.securityPolicy.allowInvalidCertificates = YES;
    //默认情况下,AFNetworking将验证证书的域名。我们的证书在每个服务器的基础上生成的,但并不是每个人都有一个域名,所以我们需要禁用:
    manager.securityPolicy.validatesDomainName = NO;
    //下面两行一定要加上, 以免各种奇葩错误
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",nil];
    return manager;
}

- (void)sendPostRequestResponseJSON:(NSURL*)url andData:(NSData*)data  andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTPTIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    WS(weakSelf);
    AFHTTPRequestOperationManager *manager = [self createAFHTTPRequestOperationManager];
    AFHTTPRequestOperation *jsonOper = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        SS(weakSelf, strongSelf)
        strongSelf.connectCount = 0;
        NSError *err;
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        DLog(@"str==%@===url=%@",str,url.absoluteString);
        NSString *temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        str = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]                  options:NSJSONReadingMutableContainers                    error:&err];
        if (err) {
            serVerBlock(nil,nil,NO);
        }else{
            serVerBlock(self,dic,YES);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        SS(weakSelf, strongSelf)
        strongSelf.connectCount += 1;
        if (strongSelf.connectCount > 3) {
            strongSelf.connectCount = 0;
            serVerBlock(nil,nil,NO);
            operation = nil;
        }else{
            [strongSelf sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
        }
    }];
    [jsonOper start];
}



-(void)sendPostRequest:(NSURL*)url andData:(NSData*)data  andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:HTTPTIMEOUT];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:data];
    WS(weakSelf);
    AFHTTPRequestOperationManager *manager = [self createAFHTTPRequestOperationManager];
    AFHTTPRequestOperation *jsonOper = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        SS(weakSelf, strongSelf)
        strongSelf.connectCount = 0;
        NSError *error = nil;
        NSString *rcvstr=[[NSString alloc] initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
        DLog(@"rcvstr==%@",rcvstr);

        //把第一个<之前的东西和最后一个>之后的东西过滤掉
        //获取第一个<的位置
        NSRange range = [rcvstr rangeOfString:@"<"];
        if (range.length>0) {
            rcvstr =  [rcvstr substringFromIndex:range.location];
        }
        //获取最后一个>的位置
        NSRange lastRange =  [rcvstr rangeOfString:@">" options:NSBackwardsSearch];
        if (lastRange.length>0) {
            rcvstr =  [rcvstr substringToIndex:lastRange.location + 1];
        }
        NSString *preParseStr = [NSString stringWithFormat:@"%@%@%@",PARSEHEADER,rcvstr,PARSEFOOTER];
        NSDictionary *dict = [XMLReader dictionaryForXMLData:[preParseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&error];
        DLog(@"dict==%@",[dict objectForKey:PARSEKEY]);
        rcvstr = nil;

        serVerBlock(nil,[dict objectForKey:PARSEKEY],YES);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        SS(weakSelf, strongSelf)
        strongSelf.connectCount += 1;
        if (strongSelf.connectCount > 3) {
            strongSelf.connectCount = 0;
            serVerBlock(nil,nil,NO);
            operation = nil;
        }else {
           [strongSelf sendPostRequest:url andData:data andblock:serVerBlock];
        }
    }];
    [jsonOper start];
}


- (NSString *)md5:(NSString *)input {
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (int)strlen(str), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];//
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

-(void)loginWithName:(NSString*)name andPwd:(NSString*)pwd andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    //登录
    NSString *imei = [SvUDIDTools UDID];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",name,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&imei=%@&lang=%@&reserved=%@&version=v2",name,pwd,s,imei,GETCountryCode,GETLang];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/login_v2",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}


-(void)registWithUserName:(NSString*)userName andPwd:(NSString*)pwd andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *imei = [SvUDIDTools UDID];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@%@",userName,SEED,pwd,imei]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&imei=%@&lang=%@&version=v2",userName,pwd,s,imei,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/register_v5",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

-(void)forgetUserName:(NSString*)userName andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *str = [NSString stringWithFormat:@"m=%@&lang=%@",userName,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/forgotpw",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

/**
 *  获取国家列表
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)getCountryListWithblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *str = [NSString stringWithFormat:@"lang=%@",GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getAreaData",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


//领取聊币
- (void)getEncourage:(NSString*)userName andPassword:(NSString*)pwd andReason:(NSString*)reason andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&reason=%@",userName,pwd,s,reason];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/freeCollectCoins",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}


//兑换聊币
- (void)exchangeCoin:(NSString*)userName andPassword:(NSString*)pwd andLeft:(NSString*)reason andWithDraw:(NSString*)withDraw andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&surplus_chatpoint=%@&ketixian=%@",userName,pwd,s,reason,withDraw];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/do_exchange",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}


/**
 *  获取国家的城市列表
 *
 *  @param countryId   <#countryId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)getCityListWithCountry:(NSString*)countryId andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *str = [NSString stringWithFormat:@"lang=%@&country_id=%@",GETCountryCode,countryId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getAreaData",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取语言
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
-(void)getspkListWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *str = [NSString stringWithFormat:@"lang=%@",GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getSpkLang",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

/**
 *  更新个人信息
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
-(void)updateInfo:(NSString*)nickName andUserId:(NSString*)userId andUser:(NSString*)email andBirthday:(NSString*)birthDay andGender:(NSString*)gender andLang:(NSString*)lang andCountry:(NSString*)country andCity:(NSString*)city andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",email,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    NSString *imei = [SvUDIDTools UDID];
    NSString *str = [NSString stringWithFormat:@"m=%@&userid=%@&s=%@&nickname=%@&birth=%@&gender=%@&spk_lang=%@&country=%@&city=%@&lang=%@&imei=%@",email,userId,s,nickName,birthDay,gender,lang,country,city,GETCountryCode,imei];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/registerMore",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}


/**
 *  删除公开照和私人照
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param seq         <#seq description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deletePersonalImg:(NSString*)userName andUserId:(NSString*)userId andSeq:(NSString*)seq andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&userid=%@&s=%@&seq=%@",userName,userId,s,seq];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/deletePic",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

/**
 *  获取所有公开照和私人照
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllImg:(NSString*)userName andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&userid=%@&s=%@",userName,userId,s];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getAllPics",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}



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
-(void)uploadAvata:(NSString*)userName andUserId:(NSString*)userId andProperty:(NSString*)property andSeq:(NSString*)seq andFileData:(NSData*)fileData andFileType:(NSString*)type andblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/uploadPic",USERSER];
    if(userId == nil){
        userId = @"";
    }
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    //自签名证书,他们在技术上“无效”,所以我们需要允许:
    manager.securityPolicy.allowInvalidCertificates = YES;
    //默认情况下,AFNetworking将验证证书的域名。我们的证书在每个服务器的基础上生成的,但并不是每个人都有一个域名,所以我们需要禁用:
    manager.securityPolicy.validatesDomainName = NO;
    //下面两行一定要加上, 以免各种奇葩错误
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",nil];
    [manager POST:urlString parameters:nil                                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //将得到的二进制图片拼接到表单中 /** data,指定上传的二进制流;name,服务器端所需参数名;fileName,指定文件名;mimeType,指定文件格式 */
        [formData appendPartWithFileData:fileData name:@"file"fileName:@"png" mimeType:[NSString stringWithFormat:@"image/%@",type]];
      
        [formData appendPartWithFormData:[userName dataUsingEncoding:NSUTF8StringEncoding] name:@"m"];
        [formData appendPartWithFormData:[s dataUsingEncoding:NSUTF8StringEncoding] name:@"s"];
        [formData appendPartWithFormData:[userId dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
        [formData appendPartWithFormData:[property dataUsingEncoding:NSUTF8StringEncoding] name:@"property"];
        
        [formData appendPartWithFormData:[seq dataUsingEncoding:NSUTF8StringEncoding] name:@"seq"];
        [formData appendPartWithFormData:[GETCountryCode dataUsingEncoding:NSUTF8StringEncoding] name:@"lang"];



        //多用途互联网邮件扩展（MIME，Multipurpose Internet Mail Extensions）

    }success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSError *error = nil;
        NSString *rcvstr=[[NSString alloc] initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
        NSString *preParseStr = [NSString stringWithFormat:@"%@%@%@",PARSEHEADER,rcvstr,PARSEFOOTER];
        DLog(@"rcvstr=%@",preParseStr);
        NSDictionary *dict = [XMLReader dictionaryForXMLData:[preParseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&error];
        rcvstr = nil;
        DLog(@"dict==%@",dict);
        serVerBlock(nil,[dict objectForKey:PARSEKEY],YES);
        //        successBlock(dict);
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        //        failBlock(error);
        serVerBlock(nil,nil,NO);
    }];
}


/**
 *  获取所有内置背景图片
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getInnerBackImgWithblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *str = [NSString stringWithFormat:@"lang=%@",GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php//api_recorder/getRecorderPics",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

/**
 *  获取所有分类 JSON格式
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getCategoryWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *str = [NSString stringWithFormat:@"lang=%@",GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php//api_recorder/getRecordCats",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 *  获取背景音乐
 *
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getBgAudioWithblock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *str = [NSString stringWithFormat:@"lang=%@",GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php//api_recorder/getEffects",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

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
- (void)uploadRecordWithMember:(NSString*)userName andUserId:(NSString*)userId andTitle:(NSString*)title andImage:(NSData*)imgData andImgType:(NSString*)imgType andAudio:(NSData*)audioData category:(NSString*)category andEffectFile1:(NSString*)effectFile1 andEffectFile1StartTime:(NSString*)effectTime1 andEffectFile2:(NSString*)effectFile2 andEffectFile2StartTime:(NSString*)effectTime2 andDuration:(int)duration andIsCharge:(NSString*)isCharge andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/uploadRec",USERSER];
    if(userId == nil){
        userId = @"";
    }
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    //自签名证书,他们在技术上“无效”,所以我们需要允许:
    manager.securityPolicy.allowInvalidCertificates = YES;
    //默认情况下,AFNetworking将验证证书的域名。我们的证书在每个服务器的基础上生成的,但并不是每个人都有一个域名,所以我们需要禁用:
    manager.securityPolicy.validatesDomainName = NO;
    //下面两行一定要加上, 以免各种奇葩错误
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",nil];
    [manager POST:urlString parameters:nil                                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //将得到的二进制图片拼接到表单中 /** data,指定上传的二进制流;name,服务器端所需参数名;fileName,指定文件名;mimeType,指定文件格式 */
        [formData appendPartWithFileData:imgData name:@"image" fileName:@"png" mimeType:[NSString stringWithFormat:@"image/%@",imgType]];
        [formData appendPartWithFileData:audioData name:@"audio" fileName:@"wav" mimeType:@"audio/x-wav"];
        
        [formData appendPartWithFormData:[userName dataUsingEncoding:NSUTF8StringEncoding] name:@"m"];
        [formData appendPartWithFormData:[s dataUsingEncoding:NSUTF8StringEncoding] name:@"s"];
        [formData appendPartWithFormData:[userId dataUsingEncoding:NSUTF8StringEncoding] name:@"userid"];
        [formData appendPartWithFormData:[title dataUsingEncoding:NSUTF8StringEncoding] name:@"title"];

        [formData appendPartWithFormData:[category dataUsingEncoding:NSUTF8StringEncoding] name:@"category"];
        [formData appendPartWithFormData:[isCharge dataUsingEncoding:NSUTF8StringEncoding] name:@"is_charge"];

        [formData appendPartWithFormData:[[NSString stringWithFormat:@"%d",duration] dataUsingEncoding:NSUTF8StringEncoding] name:@"duration"];

        [formData appendPartWithFormData:[effectFile1 dataUsingEncoding:NSUTF8StringEncoding] name:@"effect_file_1"];
        [formData appendPartWithFormData:[effectTime1 dataUsingEncoding:NSUTF8StringEncoding] name:@"effect_file_1_start_timing"];
        [formData appendPartWithFormData:[effectFile1 dataUsingEncoding:NSUTF8StringEncoding] name:@"effect_file_2"];
        [formData appendPartWithFormData:[effectTime1 dataUsingEncoding:NSUTF8StringEncoding] name:@"effect_file_2_start_timing"];
        //多用途互联网邮件扩展（MIME，Multipurpose Internet Mail Extensions）
        
    }success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSError *error = nil;
        NSString *rcvstr=[[NSString alloc] initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
        NSString *preParseStr = [NSString stringWithFormat:@"%@%@%@",PARSEHEADER,rcvstr,PARSEFOOTER];
        DLog(@"rcvstr=%@",preParseStr);
        NSDictionary *dict = [XMLReader dictionaryForXMLData:[preParseStr dataUsingEncoding:NSUTF8StringEncoding]
                                                     options:XMLReaderOptionsProcessNamespaces
                                                       error:&error];
        rcvstr = nil;
        DLog(@"dict==%@",dict);
        serVerBlock(nil,[dict objectForKey:PARSEKEY],YES);
        //        successBlock(dict);
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        //        failBlock(error);
        serVerBlock(nil,nil,NO);
    }];

}

/**
 *  获取某个人的所有电台
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllRecordsWithUser:(NSString*)userName andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock andFrom:(NSString *)from andCnt:(NSString*)cnt {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&userid=%@&s=%@&start=%@&numbers=%@",userName,userId,s,from,cnt];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/getAllRecsByMemberByPage",USERSER];
//    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsStatusByMyself",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

/**
 *  获取某个人的所有电台
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMyRecordsWithUser:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock andFrom:(NSString *)from andCnt:(NSString*)cnt {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&start=%@&numbers=%@",userName,pwd,s,from,cnt];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsStatusByMyself",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}




/**
 *  删除广播
 *
 *  @param userName    <#userName description#>
 *  @param userId      <#userId description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deleteRecordWithUser:(NSString*)userName andUserId:(NSString*)userId andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,userId]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&userid=%@&s=%@&record_id=%@",userName,userId,s,recordId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php//api_recorder/deleteRec",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}

/**
 *  获取首页列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainStationList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@",userName,pwd,s,GETCountryCode,start,numbers];
    DLog(@"str==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageMemberStatus",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 *  获取游客首页列表
 *
 *  @param gender      性别
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainStationListWithNilName:(NSString*)gender andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *str = [NSString stringWithFormat:@"lang=%@&start=%@&numbers=%@&os=ios&gender=%@",GETCountryCode,start,numbers,gender];
    DLog(@"str==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageMemberStatus",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

///查找广播
- (void)getAirportWithSearch:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andTitle:(NSString*)title andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@&title=%@",userName,pwd,s,GETCountryCode,start,numbers,title];
    DLog(@"str==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageFMBySearch",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 *  获取精品电台列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getBoutiqueStationList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andGender:(NSString*)gender andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@&os=ios&gender=%@",userName,pwd,s,GETCountryCode,start,numbers,gender];
    DLog(@"str==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsFine",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

///按分类获取广播
- (void)getBoutiqueStationListByCat:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andCat:(NSString*)cat andSort:(NSString*)sort andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&category=%@&sort=%@&start=%@&numbers=%@",userName,pwd,s,GETCountryCode,cat,sort,start,numbers];
    DLog(@"💜 str==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsByCat",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取情人动态列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainDynamicList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andGender:(NSString*)gender andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@&os=ios&gender=%@",userName,pwd,s,GETCountryCode,start,numbers,gender];
    DLog(@"str==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecords",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 *  取得某人的自我介绍档案
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param queryId     <#queryId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getIntroduceVoice:(NSString*)userName andPassword:(NSString*)pwd andQueryId:(NSString*)queryId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&query_id=%@",userName,pwd,s,GETCountryCode,queryId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getVoiceIntro",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  送礼
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param time        <#time description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)sendGift:(NSString*)userName andPassword:(NSString*)pwd andRecieveUserId:otherUserId andAmount:(NSString*)time andServerBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&userid2=%@&amount=%@",userName,pwd,s,GETCountryCode,otherUserId,time];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/sendGift",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取通话时间
 *
 *  @param sipId1      <#sipId1 description#>
 *  @param pwd         <#pwd description#>
 *  @param host
 *  @param sipId2      <#sipId2 description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getTalkMinutesWithSipID1:(NSString*)sipId1 andHost:(NSString*)host andPassword:(NSString*)pwd andSipId2:(NSString*)sipId2  andServerBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    //获取通话时间
    NSString *str = [NSString stringWithFormat:@"sipid1=%@&pass=%@&sipid2=%@",sipId1,pwd,sipId2];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"https://%@/api/api_get_talkinfo.php",host];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

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
- (void)transferTimeToServer:(NSString*)userName andPassword:(NSString*)pwd andSipId1:(NSString*)sipId1 andSipId2:(NSString*)sipId2 andCallDate:(NSString*)callDate andBillSec:(NSString*)billSec andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&sipid1=%@&sipid2=%@&calldate=%@&billsec=%@",userName,pwd,s,GETCountryCode,sipId1,sipId2,callDate,billSec];
    NSLog(@"transferTimeToServer==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_talk/decreseTalkSeconds",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取userinfo by sipid
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param sipId       <#sipId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getUserBySipId:(NSString*)userName andPassword:(NSString*)pwd andSipId:(NSString*)sipId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&sipid=%@",userName,pwd,s,sipId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMemberAllInfoBySipID",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


- (void)getAllCateByUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/getRecordCats_new",USERSER];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  检举
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param note        <#note description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)reportUserByUserName:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andNote:(NSString*)note andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&report_id=%@&lang=%@&note=%@",userName,pwd,s,otherId,GETCountryCode,note];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertReport",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  加入关注
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addFavorite:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&userid2=%@&lang=%@",userName,pwd,s,otherId,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertFavorite",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  取消关注
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deleteFavorite:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&userid2=%@&lang=%@",userName,pwd,s,otherId,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/deleteFavorite",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 *  加入封锁
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param otherId     <#otherId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addLock:(NSString*)userName andPassword:(NSString*)pwd andOtherId:(NSString*)otherId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&userid2=%@&lang=%@",userName,pwd,s,otherId,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertBlock",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取某人的关注列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param queryId     <#queryId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getFavoriteList:(NSString*)userName andPassword:(NSString*)pwd andQueryId:(NSString*)queryId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&query_id=%@&lang=%@",userName,pwd,s,queryId,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMyFavoriteMember",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  收藏某一则广播
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addCollect:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&record_id=%@&lang=%@",userName,pwd,s,recordId,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertRecordFavorite",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  取消收藏某一则广播
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)deleteCollect:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&record_id=%@&lang=%@",userName,pwd,s,recordId,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/deleteRecordFavorite",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  取得我的收藏列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param number      <#number description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllCollect:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumber:(NSString*)number  andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@",userName,pwd,s,GETCountryCode,start,number];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsStatusByMyFavorite",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  添加广播点赞
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addLikeToRecord:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&record_id=%@",userName,pwd,s,GETCountryCode,recordId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertRecordLike",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  添加广播评论
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param comment     <#comment description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)addRateToRecord:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andComment:(NSString*)comment andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&record_id=%@&comment=%@",userName,pwd,s,GETCountryCode,recordId,comment];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertRecordComment",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取评论列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getRateList:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&record_id=%@",userName,pwd,s,GETCountryCode,recordId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/getRecordCommentsByID",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 *  获取广播的基本信息
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param recordId    <#recordId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getRecordInfo:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&record_id=%@",userName,pwd,s,GETCountryCode,recordId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/getRecordById",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取全部广播列表
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param start       <#start description#>
 *  @param numbers     <#numbers description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getMainPageRecords:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBoardCastType:(BoardCastType)type andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@",userName,pwd,s,GETCountryCode,start,numbers];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsStatus",USERSER];
    if (type == BoardCastLike) {
        urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsStatusByLike",USERSER];
    }else if (type == BoardCastMine) {
        urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageRecordsStatusByMyself",USERSER];
    }
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}



/**
 *  设置曾经看过
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)setEvenSeen:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&userid2=%@",userName,pwd,s,GETCountryCode,userId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/insertEverSeen",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

/**
 *  获取用户基本资讯
 *
 *  @param userName    <#userName description#>
 *  @param pwd         <#pwd description#>
 *  @param userId      <#userId description#>
 *  @param serVerBlock <#serVerBlock description#>
 */
- (void)getPersonInfo:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&query_id=%@",userName,pwd,s,GETCountryCode,userId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getMemberAllInfoByUserid",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
  获取现有上线类别

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAliveCat:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/getAliveCat",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 获取分类照片

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getArticleContent:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/getArticleCatCover",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}



/**
 获取所有国家，其实就是进阶搜寻里获取语言

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllCountry:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getCountryList",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 根据国家Id获取城市

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param countryId   <#countryId description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllCityByCountryId:(NSString*)userName andPassword:(NSString*)pwd andCountryId:(NSString*)countryId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&country_id=%@",userName,pwd,s,GETCountryCode,countryId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getCityListByCountryId",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}



/**
 获取职业用性别

 @param gender      <#gender description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getAllJobsByGender:(NSString*)gender andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&gender=%@",userName,pwd,s,GETCountryCode,gender];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getOccupationList",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 进阶查询

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
- (void)getAdvanceSearchStationList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andFromAge:(NSString*)fromAge andToAge:(NSString*)toAge andIsOnline:(NSString*)isOnline andIdentity:(NSString*)identity andCountry:(NSString*)countryId andCity:(NSString*)cityId andJob:(NSString*)jobId andNickName:(NSString*)nickname andCharge:(NSString*)charge andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@&fromage=%@&toage=%@&online=%@&Identity=%@&spk_lang=%@&city=%@&occupation=%@&nickname=%@&charge=%@",userName,pwd,s,GETCountryCode,start,numbers,fromAge,toAge,isOnline,identity,countryId,cityId,jobId,nickname,charge];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_main/getMainPageMemberStatusBySearch",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 获取分类下的文章

 @param cateId      <#cateId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param start       <#start description#>
 @param numbers     <#numbers description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getArticleListByCategoryId:(NSString*)cateId andUserName:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@&category_id=%@",userName,pwd,s,GETCountryCode,start,numbers,cateId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/getArticleByCat",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 设置听过录音

 @param recordId    <#recordId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param time        <#time description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)setSeenWithRecord:(NSString*)recordId andUserName:(NSString*)userName andPassword:(NSString*)pwd andListenTimes:(NSString*)time andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&record_id=%@&duration=%@",userName,pwd,s,GETCountryCode,recordId,time];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/insertRecordListen",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 获取文章详情

 @param articleId   <#articleId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getArticleDetailById:(NSString*)articleId andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&product_id=%@",userName,pwd,s,GETCountryCode,articleId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/getArticleContent",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 获取某个分类我的收藏

 @param cateId      <#cateId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param start       <#start description#>
 @param numbers     <#numbers description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getMyCollectArticleWithCatId:(NSString*)cateId andUserName:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@&category_id=%@",userName,pwd,s,GETCountryCode,start,numbers,cateId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/getArticleByMyFavoriteNCat",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 文章加入收藏

 @param articleId   <#articleId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)addArticleFavoriteWithId:(NSString*)articleId andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&article_id=%@",userName,pwd,s,GETCountryCode,articleId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/insertFavoriteArticle",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 取消收藏文章

 @param articleId   <#articleId description#>
 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)cancelArticleFavoriteWithId:(NSString*)articleId andUserName:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&article_id=%@",userName,pwd,s,GETCountryCode,articleId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_article/deleteFavoriteArticle",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
  获取我的音库

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)getMyVoices:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    
//    "audio":"http://app.thevoicelover.com/upload/voice/1_20160824235314_1.mp3",	//(varchar)音檔位址
//    "seq":"1",				//(int)第幾個音檔,1:自介檔，2、3、4:罐頭語音
//    "status":"1",				//(int)審核狀態，1:未審核、2:審核通過、3:審核未通過
//    "add_time":"2016-08-24 23:53:17"	//(timestamp)新增時間

    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getAllMyVoice",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 上传自介音档和罐头音

 @param userName    <#userName description#>
 @param pwd         <#pwd description#>
 @param fileData    <#fileData description#>
 @param seq         <#seq description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)uploadVoice:(NSString*)userName andPassword:(NSString*)pwd andAudio:(NSData*)fileData andSeq:(NSString*)seq andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/uploadVoice",USERSER];

    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    //自签名证书,他们在技术上“无效”,所以我们需要允许:
    manager.securityPolicy.allowInvalidCertificates = YES;
    //默认情况下,AFNetworking将验证证书的域名。我们的证书在每个服务器的基础上生成的,但并不是每个人都有一个域名,所以我们需要禁用:
    manager.securityPolicy.validatesDomainName = NO;
    //下面两行一定要加上, 以免各种奇葩错误
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes =  [NSSet setWithObjects:@"application/json",@"text/json", @"text/javascript",@"text/html",nil];
    [manager POST:urlString parameters:nil                                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //将得到的二进制图片拼接到表单中 /** data,指定上传的二进制流;name,服务器端所需参数名;fileName,指定文件名;mimeType,指定文件格式 */
        [formData appendPartWithFileData:fileData name:@"audio" fileName:@"wav" mimeType:@"audio/x-mpeg"];
        
        [formData appendPartWithFormData:[userName dataUsingEncoding:NSUTF8StringEncoding] name:@"m"];
        [formData appendPartWithFormData:[s dataUsingEncoding:NSUTF8StringEncoding] name:@"s"];
        [formData appendPartWithFormData:[pwd dataUsingEncoding:NSUTF8StringEncoding] name:@"p"];
        
        [formData appendPartWithFormData:[seq dataUsingEncoding:NSUTF8StringEncoding] name:@"seq"];
        [formData appendPartWithFormData:[GETCountryCode dataUsingEncoding:NSUTF8StringEncoding] name:@"lang"];
        
        
        
        //多用途互联网邮件扩展（MIME，Multipurpose Internet Mail Extensions）
        
    }success:^(AFHTTPRequestOperation *operation,id responseObject){
        NSString *rcvstr=[[NSString alloc] initWithData:(NSData*)responseObject encoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject                  options:NSJSONReadingMutableContainers                    error:&err];
        
        rcvstr = nil;
        DLog(@"dict==%@",dict);
        serVerBlock(nil,dict,YES);
        //        successBlock(dict);
    }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
        //        failBlock(error);
        serVerBlock(nil,nil,NO);
    }];
}

///
- (void)getWeightList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getWeightList",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

- (void)getIdentyList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getIdentityList",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

- (void)getLockList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member/getBlockList_v1",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

- (void)getHightList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getHeightList",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}



- (void)updateInfoProfile:(NSString*)userName andPassword:(NSString*)pwd andNickName:(NSString*)nickName andBirth:(NSString*)birthDay andCountry:(NSString*)country andCity:(NSString*)city andJob:(NSString*)job andSlogan:(NSString*)slogan andHeight:(NSString*)height andWeight:(NSString*)weight andIdentity:(NSString*)identity andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&nickname=%@&birth=%@&country=%@&city=%@&occupation=%@&slogan=%@&height=%@&weight=%@&identity=%@",userName,pwd,s,GETCountryCode,nickName,birthDay,country,city,job,slogan,height,weight,identity];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/updateMyProfile",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

- (void)getMyProfile:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyProfileInfo",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


- (void)getTelCountryAndIdWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/getPhoneCode",USERSER];
    [self nomalGetMsgWithURLString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


- (NSString *)encodeToPercentEscapeString: (NSString *) input
{
    NSString *outputStr = (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)input,NULL,(CFStringRef)@"+",kCFStringEncodingUTF8));
    return outputStr;
}

- (void)getSmsCode:(NSString*)userName andPassword:(NSString*)pwd andPhoneCode:(NSString*)phoneCode andPhoneNumber:(NSString*)phoneNumer WithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&phone_code=%@&phone_number=%@",userName,pwd,s,GETCountryCode,phoneCode,phoneNumer];
    str = [self encodeToPercentEscapeString:str];

    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/sendAuthSms",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//验证验证码
- (void)validateSmsCode:(NSString*)userName andPassword:(NSString*)pwd andSMSCode:(NSString*)SMSCode andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&sms_code=%@&version=v2",userName,pwd,s,GETCountryCode,SMSCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/confirmAuthSms",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//谁来听我
- (void)getWhoListenMe:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getListenToMeList",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//谁关注我
- (void)getWhoCareMe:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getFavoriteMeList",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//通话记录
- (void)getCallRecord:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyCDR",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


///普通的json请求，只有4个参数的
- (void)nomalGetMsgWithUserName:(NSString*)userName andPassword:(NSString*)pwd andUrlString:(NSString*)urlString andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&os=ios&version=v2",userName,pwd,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

///只有lang的
- (void)nomalGetMsgWithURLString:(NSString*)urlString andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *str = [NSString stringWithFormat:@"lang=%@",GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

///普通的json请求，只有6个参数的,包含开始和个数
- (void)nomalGetMsgWithUserName:(NSString*)userName andPassword:(NSString*)pwd andUrlString:(NSString*)urlString andStart:(NSString*)start andCount:(NSString*)cnt andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&start=%@&numbers=%@",userName,pwd,s,GETCountryCode,start,cnt];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

///获取系统讯息
- (void)getMyNoticeWithUserName:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andCount:(NSString*)count andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyNotice",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andStart:start andCount:count andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//设置一则消息为读取
- (void)setReadNotice:(NSString*)userName andPassword:(NSString*)pwd andNid:(NSString*)nid andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&nid=%@",userName,pwd,s,GETCountryCode,nid];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/readANotice",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//设置全部消息为读取
- (void)setReadAllNotice:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/readAllNotice",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//删除一则消息
- (void)deleteANotice:(NSString*)userName andPassword:(NSString*)pwd andNid:(NSString*)nid andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&nid=%@",userName,pwd,s,GETCountryCode,nid];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/deleteANotice",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


//删除所有消息
- (void)deleteAllNotice:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/deleteAllNotice",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//获取设定
- (void)getNotifySetting:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMemberSetting",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//更新设定
- (void)updateNotifyChargeSetting:(NSString*)userName andPassword:(NSString*)pwd andField:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *charge = @"";
    if ([field hasPrefix:@"talk_charge"]) {
        charge = @"talk_charge";
    }else if ([field hasPrefix:@"msg_charge"]){
        charge = @"msg_charge";
    }
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&%@=%@&field=%@&value=Y",userName,pwd,s,GETCountryCode,field,value,charge];
    NSLog(@"request==%@",str);
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/updateMemberSetting",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//更新设定
- (void)updateNotifySetting:(NSString*)userName andPassword:(NSString*)pwd andField:(NSString*)field andValue:(NSString*)value andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&field=%@&value=%@",userName,pwd,s,GETCountryCode,field,value];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/updateMemberSetting",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//获取我的授权列表
- (void)getMyAuthorList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getAuthorize",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andStart:start andCount:numbers andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//授权某人
- (void)setAuthorUser:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&friend_id=%@",userName,pwd,s,GETCountryCode,userId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/insertAuthorize",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


- (void)setRecordCharge:(NSString*)userName andPassword:(NSString*)pwd andRecordId:(NSString*)recordId andIsCharge:(NSString*)isCharge andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&is_charge=%@&record_id=%@",userName,pwd,s,GETCountryCode,isCharge,recordId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_recorder/resetRec_is_charge",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//取消授权某人
- (void)deleteAuthorUser:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&friend_id=%@",userName,pwd,s,GETCountryCode,userId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/deleteAuthorize",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


//获取我的封锁列表
- (void)getMyLockList:(NSString*)userName andPassword:(NSString*)pwd andStart:(NSString*)start andNumbers:(NSString*)numbers andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getBlock",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andStart:start andCount:numbers andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//取消封锁某人
- (void)deleteLockUser:(NSString*)userName andPassword:(NSString*)pwd andUserId:(NSString*)userId andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&block_id=%@",userName,pwd,s,GETCountryCode,userId];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/deleteBlock",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//获取问答
- (void)getQuestAndAnswer:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getQnA",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//获取套餐方案
- (void)getComboProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getPaidProgram",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//获取无限畅聊方案
- (void)getLimitProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getFreeTalkProgram_v4",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//获取聊天卡方案
- (void)getTalkProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getTalkProgram_v4",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//获取电台劵方案
- (void)getRadioProgram:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getRadioProgram_v4",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//price:商品金額，USD計費
//buy_talk_second:欲購買的聊天卡秒數(ex.4500)
//buy_radio_second:欲購買的電台券秒數(ex.48000)
//subject:方案的名稱(ex.套餐一)
//body:方案的title+memo(ex. 套餐一:$30 USD 75分鐘聊天卡 + 800分鐘廣播收聽)
//pay_type:

//取得订单号码和资讯
- (void)getOrderDetail:(NSString*)userName andPassword:(NSString*)pwd andPrice:(NSString*)price andBuyTalkSecond:(NSString*)talkSeconds andRaidoSecond:(NSString*)radioSeconds andChatPoint:(NSString*)chatPoint andSubject:(NSString*)subject andBody:(NSString*)body andPayType:(NSString*)payType andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock{
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@%@",userName,SEED,pwd,price]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&price=%@&buy_talk_second=%@ &buy_chat_point=%@&buy_radio_second=%@&subject=%@&body=%@&pay_type=%@&os=ios",userName,pwd,s,GETCountryCode,price,talkSeconds,chatPoint,radioSeconds,subject,body,payType];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getOrderNum",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


//获取所有订单
- (void)getAllOrders:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getMyPaidOrder",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//获取订单交易结果
- (void)getTradeStatus:(NSString*)userName andPassword:(NSString*)pwd andOrderId:(NSString*)orderId andReceipt:(NSString*)receipt andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&ordid=%@&os=ios&receipt=%@",userName,pwd,s,GETCountryCode,orderId,receipt];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_pay/getTradeStatus",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


- (void)changePwd:(NSString*)userName andPassword:(NSString*)pwd andNewPwd:(NSString*)newPwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&newpw=%@",userName,pwd,s,GETCountryCode,newPwd];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/resetPW",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//自行删除账号
- (void)deleteSelf:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/unregisterAccount",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//取得收益内容
- (void)getProfit:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyProfit_v2",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//取得收益明细
- (void)getProfitDetail:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyProfitDetail",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//执行提领L
- (void)doWithDraw:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/do_withdraw",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}


//提领记录清单
- (void)withDrawList:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getWithdrawHistory",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//更新提领设置
- (void)updateWithDrawSetting:(NSString*)userName andPassword:(NSString*)pwd andCurrent:(NSString*)current andAccount:(NSString*)account andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&current=%@&account=%@",userName,pwd,s,GETCountryCode,current,account];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/updateWithdrawSetting",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//收益兌換聊天卡、電台券 資訊
- (void)getChangeDetail:(NSString*)userName andPassword:(NSString*)pwd andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyExchangeDetail",USERSER];
    [self nomalGetMsgWithUserName:userName andPassword:pwd andUrlString:urlString andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        serVerBlock(server,dict,ret);
    }];
}

//执行兑换
- (void)doExchange:(NSString*)userName andPassword:(NSString*)pwd andChangeTalkSecond:(NSString*)talkSecond andRadioSecond:(NSString*)radioSecond andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&exchange_talk_second=%@&exchange_radio_second=%@",userName,pwd,s,GETCountryCode,talkSecond,radioSecond];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/do_exchange",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

///获取最新聊币
- (void)getMyTime:(NSString*)userName andPassword:(NSString*)pwd andIsPhoning:(BOOL)isPhoning  andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getCreditNow",USERSER];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&phoning=%d",userName,pwd,s,GETCountryCode,isPhoning];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


//发送信息
- (void)insertMessage:(NSString*)userName andPassword:(NSString*)pwd andToMember:(NSString*)toUserId andMsgType:(NSString*)type andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",userName,SEED,pwd]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@&to_member=%@&message_type=%@",userName,pwd,s,GETCountryCode,toUserId,type];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_talk/insertMessageHistory",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


- (void)getCheckingStatusWithBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",user.userName,SEED,user.password]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",user.userName,user.password,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_config/is_ios_under_review",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//获取今日收益
- (void)getMyProfileTodayDetail:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",user.userName,SEED,user.password]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",user.userName,user.password,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyProfitTodayDetail",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//获取当月收益
- (void)getMyProfileMonthDetail:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",user.userName,SEED,user.password]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",user.userName,user.password,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyProfitMonthDetail",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}

//获取我的礼物
- (void)getMyGiftDetail:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@",user.userName,SEED,user.password]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&lang=%@",user.userName,user.password,s,GETCountryCode];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_me/getMyGifts",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequestResponseJSON:url andData:data andblock:serVerBlock];
}


/**
 <#Description#>

 @param userName <#userName description#>
 @param pwd <#pwd description#>
 @param gender <#gender description#>
 @param serVerBlock <#serVerBlock description#>
 */
- (void)registerNext:(NSString*)userName andPassword:(NSString*)pwd andGender:(NSString*)gender andBlock:(void(^)(NetAccess * server,NSDictionary *dict,BOOL ret))serVerBlock {
    NSString *imei = [SvUDIDTools UDID];
    NSString *s = [[self md5:[NSString stringWithFormat:@"%@%@%@%@",userName,SEED,pwd,imei]] substringWithRange:NSMakeRange(0, 8)];
    NSString *str = [NSString stringWithFormat:@"m=%@&p=%@&s=%@&imei=%@&lang=%@&gender=%@",userName,pwd,s,imei,GETCountryCode,gender];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php/api_member_account/register_v4",USERSER];
    NSURL *url=[NSURL URLWithString:urlString];
    [self sendPostRequest:url andData:data andblock:serVerBlock];
}


@end
