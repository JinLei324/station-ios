//
//  LonelyStationTests.m
//  LonelyStationTests
//
//  Created by zk on 15/4/27.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NetAccess.h"
#import "LonelyUser.h"

@interface LonelyStationTests : XCTestCase{
    NetAccess *_netAccess;
    LonelyUser *_user;
}

@end

@implementation LonelyStationTests

- (void)setUp {
    [super setUp];
    _netAccess = [[NetAccess alloc] init];
    _user = [[LonelyUser alloc] init];
    _user.userName = @"owenismylove@sina.com";
    _user.userID = @"2874";
    _user.password = @"123456";
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    _netAccess = nil;
    _user = nil;
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testLoginCheck{
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess loginWithName:_user.userName andPwd:@"1qaz2wsx" andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            NSLog(@"dict==%@",dict);
            XCTAssertNotNil(dict);
            XCTAssertNotNil([dict objectForKey:@"code"]);
            XCTAssertNotNil([dict objectForKey:@"userid"]);
            XCTAssert([[[dict objectForKey:@"userid"] objectForKey:@"text"] isEqualToString:@"3"]);
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testUploadImage{
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSString *type = @"png";
    NSData *fileData = UIImagePNGRepresentation([UIImage imageNamed:@"home"]);
    [_netAccess uploadAvata:_user.userName andUserId:_user.userID andProperty:@"public" andSeq:@"5" andFileData:fileData andFileType:type andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            NSLog(@"dict==%@",dict);
            XCTAssertNotNil(dict);
            XCTAssertNotNil([dict objectForKey:@"code"]);
            XCTAssertNotNil([dict objectForKey:@"img"]);
            XCTAssert([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]);

        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testRegisterUser{
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess registWithUserName:@"719865682@qq.com" andPwd:@"1qaz2wsx" andblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
            XCTAssertNotNil([dict objectForKey:@"code"]);
            if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                XCTAssertNotNil([dict objectForKey:@"userid"]);
            }
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


- (void)testGetInnerRecord {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getInnerBackImgWithblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
            XCTAssertNotNil([dict objectForKey:@"oneRow"]);
       
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


- (void)testGetCategoryWithBlock {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getCategoryWithBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testGetBgAudipWithBlock {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getBgAudioWithblock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

//上传广播
- (void)testUploadRecord {
    //测试分类 103 学校
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"leftbackiamge" ofType:@"png"]];
    NSData *audioData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserRecordTemp" ofType:@"wav"]];
    [_netAccess uploadRecordWithMember:_user.userName andUserId:_user.userID andTitle:@"测试广播" andImage:imgData andImgType:@"png" andAudio:audioData category:@"103" andEffectFile1:@"2" andEffectFile1StartTime:@"00:00:02" andEffectFile2:@"3" andEffectFile2StartTime:@"00:00:06" andDuration:10 andIsCharge:@"N" andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:180.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

//获取所有电台
- (void)testGetAllRecord {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getAllRecordsWithUser:_user.userName andUserId:_user.userID andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    } andFrom:@"0" andCnt:@"10"];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


//删除电台
- (void)testDeleteRecord {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess deleteRecordWithUser:_user.userName andUserId:_user.userID andRecordId:@"119" andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testGetmainStation {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getMainStationList:_user.userName andPassword:_user.password andStart:@"0" andNumbers:@"20" andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        NSLog(@"dict== %@",dict);
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testGetIntroduceVoice {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getIntroduceVoice:_user.userName andPassword:_user.password andQueryId:@"2888" andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        NSLog(@"dict== %@",dict);
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testGetUserBySipId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getUserBySipId:_user.userName andPassword:_user.password andSipId:@"8868180002874" andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        NSLog(@"dict== %@",dict);
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


- (void)testGetLiveCat {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getAliveCat:_user.userName andPassword:_user.password  andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        NSLog(@"dict== %@",dict);
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


- (void)testGetWight {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getWeightList:_user.userName andPassword:_user.password  andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        NSLog(@"dict== %@",dict);
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testGetHight {
    XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    [_netAccess getHightList:_user.userName andPassword:_user.password  andBlock:^(NetAccess *server, NSDictionary *dict, BOOL ret) {
        NSLog(@"dict== %@",dict);
        if(dict){
            XCTAssertNotNil(dict);
            
        }else{
            XCTAssert(ret==NO,@"Pass");
        }
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:20.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
