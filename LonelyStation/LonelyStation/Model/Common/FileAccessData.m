//
//  FileAccessData.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "FileAccessData.h"
#import "YTKKeyValueStore.h"
#define DBNAME @"lsdb.db"
#define TABLENAME @"ls_table"

@implementation FileAccessData

@synthesize commonDict = _commonDict;

static FileAccessData *_sharedInstance;

+ (FileAccessData *)sharedInstance{
    static dispatch_once_t onceman;
    dispatch_once(&onceman, ^{
        _sharedInstance = [[self alloc] init];
        YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:DBNAME];
        [store createTableWithName:TABLENAME];
    });
    return _sharedInstance;
}


- (void)setMemObject:(id)Object forKey:(NSString*)key {
    if (!_commonDict) {
        _commonDict = [NSMutableDictionary dictionary];
    }
    [_commonDict setObject:Object forKey:key];
}


- (id)objectForMemKey:(NSString*)key{
    if (!_commonDict) {
        return nil;
    }else {
        return [_commonDict objectForKey:key];
    }
}

-(void)setAObject:(id)Object forEMKey:(NSString*)key{
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:DBNAME];
    NSDictionary *dict =[Object yy_modelToJSONObject];
    if (dict == nil) {
        if ([Object isKindOfClass:[NSString class]]) {
            [store putString:Object withId:key intoTable:TABLENAME];
        }else if([Object isKindOfClass:[NSNumber class]]){
            [store putNumber:Object withId:key intoTable:TABLENAME];
        }
    }else{
        [store putObject:dict withId:key intoTable:TABLENAME];
    }
}

-(id)objectForEMKey:(NSString*)key{
    YTKKeyValueStore *store = [[YTKKeyValueStore alloc] initDBWithName:DBNAME];
    id queryUser = [store getObjectById:key fromTable:TABLENAME];
    return queryUser;
}


@end
