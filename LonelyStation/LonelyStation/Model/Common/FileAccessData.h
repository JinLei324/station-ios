//
//  FileAccessData.h
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileAccessData : NSObject

+ (FileAccessData *)sharedInstance;

@property(nonatomic,strong)NSMutableDictionary *commonDict;


-(void)setAObject:(id)Object forEMKey:(NSString*)key;

-(id)objectForEMKey:(NSString*)key;

- (void)setMemObject:(id)Object forKey:(NSString*)key;

- (id)objectForMemKey:(NSString*)key;

@end
